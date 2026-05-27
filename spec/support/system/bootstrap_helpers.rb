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

    def bootstrap_wrapper(selector)
      # Evaluates fresh every time. No node traps.
      find("select#{selector}", visible: :hidden).ancestor('.bootstrap-select', match: :first)
    end

    def bootstrap_multiselect(selector, selections: ['all'])
      # Playbook IV: Rescue Loop for Complex Chains (No Sleeps!)
      retries = 5
      begin
        bootstrap_wrapper(selector).find('.dropdown-toggle').click
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        retries -= 1
        retry if retries > 0
        raise "StaleElementReferenceError exhausted 5 retries targeting #{selector}"
      end

      # Playbook V: Wait for Animations natively
      expect(bootstrap_wrapper(selector)).to have_css('.dropdown-menu.show')

      if selections.include?('all')
        bootstrap_wrapper(selector).find('.dropdown-menu.show button.bs-select-all').click
      else
        selections.each do |selection|
          bootstrap_wrapper(selector).find('.dropdown-menu.show span.text', text: selection, exact_text: true).click
        end
      end

      bootstrap_wrapper(selector).find('.dropdown-toggle').click
      
      # Sync point: natively wait for the menu to completely close
      expect(bootstrap_wrapper(selector)).to have_no_css('.dropdown-menu.show')
    end

    def bootstrap_select(selector, choice, context_selector: nil)
      action = proc do
        # Playbook IV: Rescue Loop (No Sleeps!)
        retries = 5
        begin
          bootstrap_wrapper(selector).find('.dropdown-toggle').click
        rescue Selenium::WebDriver::Error::StaleElementReferenceError
          retries -= 1
          retry if retries > 0
          raise "StaleElementReferenceError exhausted 5 retries targeting #{selector}"
        end

        expect(bootstrap_wrapper(selector)).to have_css('.dropdown-menu.show')
        
        bootstrap_wrapper(selector).find('.dropdown-menu.show span.text', text: choice, exact_text: true, visible: true).click
        
        # Polling validation: Ensure the choice actually registered in the UI
        expect(bootstrap_wrapper(selector)).to have_css(".filter-option-inner-inner", text: choice, exact_text: true)
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

        within('.datepicker, .bootstrap-datetimepicker-widget') do
          find('.year', text: year.to_s, exact_text: true).click if year
          find('.month', text: month.to_s, exact_text: true).click if month
          find('.day', text: day.to_s, exact_text: true).click if day
        end
      else
        input.click
        input.set(text)
        
        # Playbook IV: Native Blur Event
        find('body').click(x: 0, y: 0) 
      end
    end
  end
end