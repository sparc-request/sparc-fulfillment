module Features

  module BootstrapHelpers

    def bootstrap_select(element, choice)
      within '.bootstrap-select' do
        page.find(element).click

        within '.dropdown-menu.selectpicker' do
          page.find('a', text: choice).click
        end
      end

      sleep 2
    end
  end
end
