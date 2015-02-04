module Features

  module BrowserHelpers

    def click_browser_back_button
      page.evaluate_script('window.history.back()')
    end
  end
end
