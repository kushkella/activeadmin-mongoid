require 'active_admin'
require 'inherited_resources'

ActiveAdmin::Resource # autoload
class ActiveAdmin::Resource
  def resource_table_name
    if (resource_class.included_modules.include? Mongoid::Document)
      return resource_class.collection_name
    else
      return resource_class.quoted_table_name
    end
  end
end

ActiveAdmin::ResourceController # autoload
class ActiveAdmin::ResourceController
  before_filter :skip_sidebar!

  protected

  def skip_sidebar!
	if(resource_class.included_modules.include? Mongoid::Document)
		@skip_sidebar = true
	end
  end

  # Use #desc and #asc for sorting.
  def sort_order(chain)
	if (resource_class.included_modules.include? Mongoid::Document)
      params[:order] ||= active_admin_config.sort_order
      table_name = active_admin_config.resource_table_name
      if params[:order] && params[:order] =~ /^([\w\_\.]+)_(desc|asc)$/
        chain.send($2, $1)
      else
        chain # just return the chain
      end
	else
	  params[:order] ||= active_admin_config.sort_order
	  if params[:order] && params[:order] =~ /^([\w\_\.]+)_(desc|asc)$/
		column = $1
		order  = $2
		table  = active_admin_config.resource_table_name
		table_column = (column =~ /\./) ? column :
		  "#{table}.#{active_admin_config.resource_quoted_column_name(column)}"

		chain.reorder("#{table_column} #{order}")
	  else
		chain # just return the chain
	  end
	end
  end

  # Disable filters
  def search(chain)
	if (resource_class.included_modules.include? Mongoid::Document)
		chain
	else
		@search = chain.metasearch(clean_search_params(params[:q]))
		@search.relation
	end
  end
end