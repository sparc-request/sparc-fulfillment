module Features

  module BootstrapTableHelpers

    def search_bootstrap_table(query)
      page.find('.search > input').set(query)
    end

    def refresh_bootstrap_table(table, url=nil)
      if url.present?
        page.execute_script "$('#{ table }').bootstrapTable('refresh', {url: '#{url}', silent: 'true' })"
      else
        page.execute_script "$('#{ table }').bootstrapTable('refresh', { silent: 'true' })"
      end
    end
  end
end
