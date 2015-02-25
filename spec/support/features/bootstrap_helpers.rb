module Features

  module BootstrapHelpers

    def bootstrap_select(class_or_id, choice)
      bootstrap_select  = page.find("select#{class_or_id} + .bootstrap-select")
      bootstrap_select.click
      within bootstrap_select do
        page.find('a', text: choice).click
      end
    end

    def bootstrap_selected?(element, choice)
      page.find("button.selectpicker[data-id='#{element}'][title='#{choice}']")
    end
  end
end

