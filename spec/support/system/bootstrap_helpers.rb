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

module System
  module BootstrapHelpers
    def pick_new_date(old_date)
      (1..20).reject { |day| day == old_date }.sample
    end

    def bootstrap_multiselect(selector, selections: ['all'])
      # Find the hidden select, then anchor to its wrapper. 
      # This completely eliminates StaleElement errors by locking the search scope.
      wrapper = find("select#{selector}", visible: :hidden).ancestor('.bootstrap-select', match: :first)

      within(wrapper) do
        # Capybara naturally waits for this to become clickable
        find('.dropdown-toggle').click

        # Wait implicitly for the menu to open before proceeding
        within('.dropdown-menu.show') do
          if selections.include?('all')
            find('button.bs-select-all').click
          else
            selections.each do |selection|
              find('span.text', text: selection, exact_text: true).click
            end
          end
        end

        # Close the dropdown natively to blur the UI and trigger JS listeners
        # No send_keys(:escape) required.
        find('.dropdown-toggle').click
        expect(wrapper).to have_no_css('.dropdown-menu.show') # SYNC POINT
      end
    end

    def bootstrap_select(selector, choice, context_selector: nil)
      action = proc do
        wrapper = find("select#{selector}", visible: :hidden).ancestor('.bootstrap-select', match: :first)

        within(wrapper) do
          # 1. Click toggle
          find('.dropdown-toggle').click

          # 2. THE HARDENED SYNC POINT: 
          # We wait until the menu exists AND has the 'show' class, 
          # proving the animation is finished.
          expect(page).to have_css('.dropdown-menu.show')
          
          # 3. Use a more robust selector that ensures the span is visible
          find('.dropdown-menu.show span.text', text: choice, exact_text: true, visible: true).click
        end
        
        expect(wrapper).to have_css(".filter-option-inner-inner", text: choice, exact_text: true)
      end

      context_selector ? within(context_selector, &action) : action.call
    end

    def bootstrap_selected?(element_id, choice)
      expect(page).to have_css("button.dropdown-toggle[data-id='#{element_id}'][title='#{choice}']")
    end

    def bootstrap_datepicker(selector, year: nil, month: nil, day: nil, text: nil)
      input = find(selector)

      if input.readonly?
        input.click

        # Capybara automatically waits up to Capybara.default_max_wait_time for this wrapper to spawn.
        # No need for hardcoded wait: 5 counts.
        within('.datepicker, .bootstrap-datetimepicker-widget') do
          find('.year', text: year.to_s, exact_text: true).click if year
          find('.month', text: month.to_s, exact_text: true).click if month
          find('.day', text: day.to_s, exact_text: true).click if day
        end
      else
        input.click
        input.set(text)
        
        # Click the body to natively blur the input and fire "onChange" jQuery listeners
        # Bypasses the need for JS injection or brittle send_keys.
        find('body').click(x: 0, y: 0) # Safely clicks the top left corner pixel
      end
    end
  end
end