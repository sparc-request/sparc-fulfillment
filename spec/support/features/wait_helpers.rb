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
  module WaitHelpers
    def wait_for_page(path)
      Selenium::WebDriver::Wait.new(timeout: Capybara.default_max_wait_time).until{ current_path == path }
    end

    def wait_for_ajax
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop until finished_all_network_requests?
      end
    rescue Timeout::Error
      raise "AJAX/Fetch requests did not complete within #{Capybara.default_max_wait_time} seconds."
    end

    def finished_all_network_requests?
      page.evaluate_script(<<~JS)
        (function() {
          // 1. Check legacy jQuery
          var jqueryActive = (typeof jQuery !== 'undefined' ? jQuery.active : 0);
          
          // 2. Check modern Rails Turbo (if Turbo is actively making a request)
          var turboActive = false;
          if (typeof document !== 'undefined' && document.documentElement) {
            turboActive = document.documentElement.hasAttribute('data-turbo-preview');
          }
          
          return jqueryActive === 0 && !turboActive;
        })()
      JS
    end

#     def wait_for_ajax
#       Timeout.timeout(Capybara.default_max_wait_time) do
#         loop until jquery_defined?
#         loop until finished_all_ajax_requests? && finished_all_animations?
#       end
#     end

#     def jquery_defined?
#       page.evaluate_script(%Q{typeof jQuery !== 'undefined'}) && page.evaluate_script(%Q{typeof $ !== 'undefined'})
#     end

#     def finished_all_ajax_requests?
#       page.evaluate_script('jQuery.active') == 0
#     end

#     def finished_all_ajax_requests?
#       # Move the JS to a variable so VSCode can "see" the closing parens clearly
#       check_js = <<~JS
#         (function() {
#           var jqueryActive = (typeof jQuery !== 'undefined' ? jQuery.active : 0);
#           return jqueryActive === 0 && (!window.fetch || true);;
#         })()
#       JS

#       page.evaluate_script(check_js)
#     end

#     # def finished_all_ajax_requests?
#     #   # This version checks jQuery AND waits for any active 'fetch' or 'XHR' 
#     #   # that might be happening outside of jQuery
#     #   page.evaluate_script("typeof jQuery !== 'undefined' ? jQuery.active : 0") == 0
#     # end

#     def finished_all_animations?
#       page.evaluate_script('$(":animated").length') == 0
#     end
  end
end
