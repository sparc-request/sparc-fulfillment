require 'rails_helper'

RSpec.describe AppointmentStatus, type: :model do

  it { is_expected.to belong_to(:appointment) }

end 