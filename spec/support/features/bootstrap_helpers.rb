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

module Features
  module BootstrapHelpers
    def pick_new_date(old_date)
      (1..20).to_a.reject{|day| day == old_date}.sample
    end

    def bootstrap_multiselect(class_or_id, selections = ['all'])
      retries = 0
      begin
        retries ||= 0
        expect(page).to have_selector("select#{class_or_id}", visible: :all)
        bootstrap_multiselect = first("select#{class_or_id}", visible: :all).sibling(".dropdown-toggle")
      rescue Selenium::WebDriver::Error::StaleElementReferenceError, Capybara::ElementNotFound
        sleep 1
        retry if (retries += 1) < 5
      end
      
      bootstrap_multiselect.click

      expect(page).to have_selector('.dropdown-menu.show')
      if selections.first == 'all'
        first('.dropdown-menu.show button.bs-select-all').click
      else
        selections.each do |selection|
          first('.dropdown-menu.show span.text', text: selection).click
        end
      end

      find('body').native.send_keys(:escape)
      wait_for_ajax
    end

    def bootstrap_select(class_or_id, choice, context_selector = '')
      retries = 0 
      
      begin
        hidden_select = find("#{context_selector} select#{class_or_id}", visible: :all, match: :first)
        container = hidden_select.find(:xpath, '../..', visible: :all)

        within(container) do
          toggle_button = find('.dropdown-toggle', visible: :all, match: :first)
          
          page.execute_script("arguments[0].click();", toggle_button)
          
          within('.dropdown-menu', visible: :all, match: :first) do
            option = find('span.text', text: choice, exact_text: true, visible: :all, match: :first)
            page.execute_script("arguments[0].click();", option)
          end
        end
        
        expect(page).to have_css(".filter-option-inner-inner", text: choice, visible: :all, match: :first)

      rescue Capybara::ElementNotFound, Selenium::WebDriver::Error::StaleElementReferenceError => e
        # Our safety net for legitimate race conditions
        sleep 0.5 
        retry if (retries += 1) < 2
        raise e
      end
    end

    def bootstrap_selected?(element, choice)
      page.find("button.dropdown-toggle[data-id='#{element}'][title='#{choice}']")
    end

    def bootstrap_datepicker(element, args={})
      e = page.find(element, wait: 5)

      if e['readonly'] || e['readonly'] == 'readonly'
        # HOVER LOCK: The input is likely inside a modal or recently rendered div. Wait for movement to stop and JS listeners to attach before clicking.
        e.hover
        e.click

        # SYNC POINT: Guarantee the widget spawned. If the click was swallowed by an animation, this catches it immediately instead of failing later. 
        expect(page).to have_css('.datepicker, .bootstrap-datetimepicker-widget', wait: 5)

        if args[:year]
          # Removed "visible: :all". Capybara should naturally wait until the calendar view transitions and the element becomes visible.
          year_opt = find('.year', exact_text: args[:year].to_s, wait: 5)
          year_opt.hover
          year_opt.click
        end

        if args[:month]
          month_opt = find('.month', exact_text: args[:month].to_s, wait: 5)
          month_opt.hover
          month_opt.click
        end

        if args[:day]
          day_opt = find('.day', exact_text: args[:day].to_s, wait: 5)
          day_opt.hover
          day_opt.click
        end
      else
        # Bypassing pure JS injection. Standard DOM events should fire NATIVELY so custom jQuery listeners don't get ignored during the input sequence.
        e.hover
        e.click
        e.set(args[:text])
      end
    end
  end
end
