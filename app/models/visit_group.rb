# Copyright © 2011-2023 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class VisitGroup < ApplicationRecord
  self.per_page = Visit.per_page

  has_paper_trail
  acts_as_paranoid
  acts_as_list scope: 'arm_id = #{arm_id} AND deleted_at IS NULL'

  belongs_to :arm

  has_many :visits, dependent: :destroy
  has_many :appointments, dependent: :destroy

  has_many :line_items, through: :arm
  has_many :procedures, through: :appointments

  default_scope { order(:position) }

  validates :arm_id, presence: true
  validates :name, presence: true
  validates :window_before,
            :window_after,
            presence: true, numericality: { only_integer: true }
  validates :day, presence: true, unless: -> { ENV.fetch('USE_EPIC'){nil} == 'false' }
  validate :day_must_be_in_order, unless: -> { day.blank? || arm_id.blank? }
  validates :day, numericality: { only_integer: true }, unless: -> { day.blank? }

  after_create :create_appointments
  after_update :update_appointments

  def identifier
    "#{self.name} (#{self.class.human_attribute_name(:day)} #{self.day})"
  end

  def r_quantities_grouped_by_service
    visits.joins(:line_item).group(:service_id).sum(:research_billing_qty)
  end

  def t_quantities_grouped_by_service
    visits.joins(:line_item).group(:service_id).sum(:insurance_billing_qty)
  end

  def destroy
    if can_be_destroyed?
      super
    else
      raise ActiveRecord::ActiveRecordError
    end
  end

  def can_be_destroyed?
    procedures.where.not(status: 'unstarted').empty?
  end

  private

  def create_appointments
    # GEM NOTE:  some methods like 'move_to_bottom', 'last?', and 'move_higher' reference the acts_as_list gem.  Check that gem's documentation on github for anything you're uncertain about

    # If the arm this visit group belongs to has protocols_participants (a.k.a. test subjects)...
    if self.arm.protocols_participants
      # ...then for each subject...
      self.arm.protocols_participants.each do |pp|
        # ...check if the subject has any appointments...
        if pp.appointments.where(arm: self.arm).none?
          # ...if not, go ahead and create all appointments for all of the arm's visit groups
          self.arm.visit_groups.each do |vg|
            pp.appointments.create(arm: vg.arm, visit_group: vg, name: vg.name, visit_group_position: vg.position, position: vg.position)
          end
        # ...if the subeject *has* appointments, we just need to create all missing appointments...
        else
          #...find all missing appointments and then create them but ignore order (we'll fix the positioning in a bit)...
          missing_appointments_by_visit_group_ids = self.arm.visit_groups.pluck(:id).difference(pp.appointments.where(arm: self.arm).pluck(:visit_group_id))
          missing_appointments_by_visit_group_ids.each do |missing_vg|
            vg = VisitGroup.find(missing_vg)
            pp.appointments.create(arm: vg.arm, visit_group: vg, name: vg.name, visit_group_position: vg.position, position: nil)
          end

          #...now, re-order all appointments that are associated with a visit group for this subject to match the ordering of visit groups on the arm
          pp.appointments.where(arm: self.arm).where.not(visit_group: nil).each do |appt|
            #Check if current appointment *should* be at the bottom of the appointment list...
            if appt.visit_group.last?
              #...if so, move appointment to the bottom of the list
              appt.move_to_bottom
            #...if not, check if appointment is currently at the bottom of the list
            elsif appt.last? && !(appt.higher_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.higher_item)
              #...if it is at the bottom, then we know the position it's changing to is somehwere higher in the list since we just established which appointment is supposed to be at the bottom of the list so move it...
              until !appt.last? and (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                appt.move_higher
              end
            #...if appointment is not at the bottom of the list, check if it's at the top (and make sure that it's not *supposed* to be at the top)...
            elsif appt.first? && !appt.visit_group.first? && !(appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item)
              #...if it is at the top, then we know the position is changing to somewhere lower in the list so move it...
              until !appt.first? and (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                appt.move_lower
              end
            #...if the appointment is not supposed to be at the bottom of the list and is currently neither at the top of the list nor at the bottom, we can safely assume that there are supposed to appointments beneath it so check if the next appointment associated with a visit_group in the list matches with the next visit_group in the list for the arm...
            elsif appt.lower_items.where.not(visit_group: nil).first.visit_group != appt.visit_group.lower_item
              #...if it doesn't match, then let's check if the appointment that is supposed to be next is currently higher in the list...
              if appt.higher_items.where.not(visit_group: nil).pluck(:visit_group_id).include?(appt.visit_group.lower_item.id)
                #...if the appointment we're looking for *is* higher in the list, then move the current appointment up the list until the next appointment associated with a visit_group is the expected one
                until appt.first? or (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                  appt.move_higher
                end
              #...if the appointment we're looking for *isn't* higher in the list, we can safely assume that it's currently lower in the list...  
              else
                #...so move the current appointment down the list until the next appointment associated with a visit_group is the expected one
                until appt.last? or (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                  appt.move_lower
                end
              end
            end
          end
        end
      end
    end
  end

  def update_appointments
    # GEM NOTE:  some methods like 'move_to_bottom', 'last?', and 'move_higher' reference the acts_as_list gem.  Check that gem's documentation on github for anything you're uncertain about

    #WARNING TO FUTURE DEVS:  This callback is going to be very complicated because the order of presentation matters in the apppointments list.  Further, we have to account for the possibility of arbitrary custom appointments that can be added to each subject which are not visible to the visit group but whose order matters for the specific subject in question.  All of this means we can't simply work off of the visit group position for the ordering and re-ordering of appointments but have to customize the position of each individual appointment within the unique context of the appointment list of a given subject.

    # If the arm this visit group belongs to has protocols_participants (a.k.a. test subjects)...
    if self.arm.protocols_participants
      # ...then for each subject...
      self.arm.protocols_participants.each do |pp|
        # ...check if the subject has any appointments...
        if pp.appointments.where(arm: self.arm).none?
          # ...if not, go ahead and create all appointments for all of the arm's visit groups
          self.arm.visit_groups.each do |vg|
            pp.appointments.create(arm: vg.arm, visit_group: vg, name: vg.name, visit_group_position: vg.position, position: vg.position)
          end
        #...if the subject *has* appointments already, then we should...
        else
          #...check whether the subject is missing any appointments that we'd expect them to have based on the current arm...
          missing_appointments_by_visit_group_ids = self.arm.visit_groups.pluck(:id).difference(pp.appointments.where(arm: self.arm).pluck(:visit_group_id))
          if missing_appointments_by_visit_group_ids.any?
            #...if so, create all missing appointments but ignore order (we'll fix the positioning in a bit)
            missing_appointments_by_visit_group_ids.each do |missing_vg|
              vg = VisitGroup.find(missing_vg)
              pp.appointments.create(arm: vg.arm, visit_group: vg, name: vg.name, visit_group_position: vg.position, position: nil)
            end

            #...next, update the appointment for this subject that corresponds to the visit_group that was actually updated in the first place (again, without worrying about position yet)
            pp.appointments.where(visit_group: self).update(name: self.name, visit_group_position: self.position)

            #...finally, re-order all appointments that are associated with a visit group for this subject to match the ordering of visit groups on the arm
            pp.appointments.where(arm: self.arm).where.not(visit_group: nil).each do |appt|
              #Check if current appointment is supposed to be at the bottom of the appointment list...
              if appt.visit_group.last?
                #...if so, move appointment to the bottom of the list
                appt.move_to_bottom
              #...if not, check if appointment is currently at the bottom of the list
              elsif appt.last? && !(appt.higher_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.higher_item)
                #...if it is at the bottom, then we know the position it's changing to is somehwere higher in the list so move it...
                until !appt.last? and (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                  appt.move_higher
                end
              #...if appointment is not at the bottom of the list, check if it's at the top (and make sure it's not supposed to be at the top)...
              elsif appt.first? && !appt.visit_group.first? && !(appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item)
                #...if it is at the top, then we know the position is changing to somewhere lower in the list so move it...
                until !appt.first? and (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                  appt.move_lower
                end
              #...if the appointment is neither at the top of the list nor at the bottom, we can safely assume that there are supposed to appointments beneath it so check if the next appointment associated with a visit_group in the list matches with the next visit_group in the list for the arm...
              elsif appt.lower_items.where.not(visit_group: nil).first.visit_group != appt.visit_group.lower_item
                #...if it doesn't match, then let's check if the appointment that is supposed to be next is currently higher in the list...
                if appt.higher_items.where.not(visit_group: nil).pluck(:visit_group_id).include?(appt.visit_group.lower_item.id)
                  #...if the appointment we're looking for *is* higher in the list, then move the current appointment up the list until the next appointment associated with a visit_group is the expected one
                  until appt.first? or (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                    appt.move_higher
                  end

                #...if the appointment we're looking for *isn't* higher in the list, we can safely assume that it's currently lower in the list...  
                else
                  #...so move the current appointment down the list until the next appointment associated with a visit_group is the expected one
                  until appt.last? or (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                    appt.move_lower
                  end
                end
              end
            end
          #...if, on the other hand, the subject is *not* missing any appointments, then we just need update the current appointment and move it to the correct position
          else
            appt = pp.appointments.where(visit_group: self).first

            #...before updating, check to see if there's been a change to the visit_group's position
            visit_group_position_changed = !(appt.visit_group_position == appt.visit_group.position)

            appt.update(name: self.name, visit_group_position: self.position)

            # Only bother with the rest if the position of this visit group position actually changed...
            if visit_group_position_changed
              #Check if current appointment is *supposed* to be at the bottom of the appointment list...
              if appt.visit_group.last?
                #...if so, move appointment to the bottom of the list
                appt.move_to_bottom
              #...if not, check if appointment is currently at the bottom of the list
              elsif appt.last?
                #...if it is at the bottom, then we know the position it's changing to is somehwere higher in the list so move it...
                until !appt.last? and (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                  appt.move_higher
                end
              #...if appointment is not at the bottom of the list, check if it's at the top...
              elsif appt.first? && !appt.visit_group.first? && !(appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item)
                #...if it is at the top, then we know the position is changing to somewhere lower in the list so move it...
                until !appt.first? and (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                  appt.move_lower
                end
              #...if the appointment is neither at the top of the list nor at the bottom, we can safely assume that there are supposed to appointments beneath it so check if the next appointment associated with a visit_group in the list matches with the next visit_group in the list for the arm...
              elsif appt.lower_items.where.not(visit_group: nil).first.visit_group != appt.visit_group.lower_item
                #...if it doesn't match, then let's check if the appointment that is supposed to be next is currently higher in the list...
                if appt.higher_items.where.not(visit_group: nil).pluck(:visit_group_id).include?(appt.visit_group.lower_item.id)
                  #...if the appointment we're looking for *is* higher in the list, then move the current appointment up the list until the next appointment associated with a visit_group is the expected one
                  until appt.first? or (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                    appt.move_higher
                  end
                #...if the appointment we're looking for *isn't* higher in the list, we can safely assume that it's currently lower in the list... 
                else
                  #...so move the current appointment down the list until the next appointment associated with a visit_group is the expected one
                  until appt.last? or (appt.lower_items.where.not(visit_group: nil).first.visit_group == appt.visit_group.lower_item) do
                    appt.move_lower
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  # Used to validate :day, when present. Preceding VisitGroup must have a
  # smaller :day, and succeeding VisitGroup must have a larger :day (on same Arm).
  def day_must_be_in_order
    already_there = arm.visit_groups.find_by(position: position) || arm.visit_groups.find_by(id: id)
    last_persisted_pos = arm.visit_groups.last.try(:position) || 0

    # determine neighbors that will be after save
    left_neighbor, right_neighbor =
      if id.nil? # inserting new record
        if position.nil? # insert as last
          [arm.visit_groups.last, nil]
        elsif position <= last_persisted_pos # inserting before
          [already_there.try(:higher_item), already_there]
        end
      else # moving present record
        if already_there.try(:id) == id # not changing position, get our neighbors
          [higher_item, lower_item]
        else # position must be changing
          if already_there.position < changed_attributes[:position]
            [already_there.try(:higher_item), already_there]
          else
            [already_there, already_there.try(:lower_item)]
          end
        end
      end

    if left_neighbor.try(:id) == id
      left_neighbor = nil
    end

    unless day > (left_neighbor.try(:day) || day - 1) && day < (right_neighbor.try(:day) || day + 1)
      errors.add(:day, 'must be in order')
    end
  end
end
