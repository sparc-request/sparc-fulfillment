module Features

  module BootstrapHelpers

    def bootstrap_multiselect(class_or_id, selections)
      bootstrap_multiselect = page.find("select#{class_or_id} + .btn-group")

      save_and_open_screenshot
      bootstrap_multiselect.click
    end

    def bootstrap_select(class_or_id, choice)
      bootstrap_select = page.find("select#{class_or_id} + .bootstrap-select")

      bootstrap_select.click
      within bootstrap_select do
        first('a', text: choice).click
      end
    end

    def bootstrap_selected?(element, choice)
      page.find("button.selectpicker[data-id='#{element}'][title='#{choice}']")
    end
  end
end

