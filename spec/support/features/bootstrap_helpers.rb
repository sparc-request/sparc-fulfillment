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

      #This caused problems,
      #because it ACTUALLY clicks on the center of the page,
      #and if that happens to be something to actually click on...

      # find('body').click # Click away

      ##

      find('body').native.send_keys(:escape)
      wait_for_ajax
    end

    def bootstrap_select(class_or_id, choice, context_selector = '')
      retries = 0 
      
      begin
        # 1. Grab the hidden select and its container, ignoring Geckodriver visibility rules
        hidden_select = find("#{context_selector} select#{class_or_id}", visible: :all, match: :first)
        container = hidden_select.find(:xpath, '../..', visible: :all)

        within(container) do
          # 2. Find the UI toggle button, bypassing visibility checks
          toggle_button = find('.dropdown-toggle', visible: :all, match: :first)
          
          # 3. Fire a native browser click directly on the UI element 
          page.execute_script("arguments[0].click();", toggle_button)
          
          # 4. Scope to the first menu to avoid Ambiguous match errors
          within('.dropdown-menu', visible: :all, match: :first) do
            option = find('span.text', text: choice, exact_text: true, visible: :all, match: :first)
            page.execute_script("arguments[0].click();", option)
          end
        end
        
        # 5. Assert the UI updated successfully (This proves the clicks actually worked)
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
      e = page.find(element)

      if e['readonly']
        # NATIVE FIX: Use the exact node we just waited for, letting Capybara auto-retry if it stales
        e.click

        if args[:year]
          expect(page).to have_selector('.year', exact_text: args[:year], visible: :all, wait: 5)
          first('.year', exact_text: args[:year]).click
        end

        if args[:month]
          expect(page).to have_selector('.month', exact_text: args[:month], visible: :all, wait: 5)
          first('.month', exact_text: args[:month]).click
        end

        if args[:day]
          expect(page).to have_selector('.day', exact_text: args[:day], visible: :all, wait: 5)
          first('.day', exact_text: args[:day]).click
        end
      else
        page.execute_script "$('#{element}').focus()"
        page.execute_script "$('#{element}').focus()" unless page.has_css?('bootstrap-datetimepicker-widget')
        e.send_keys(:delete)
        e.set(args[:text])
      end
    end
  end
end
