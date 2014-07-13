class ItemsDynatable
  delegate :params, :h, :link_to, :number_to_currency, :simple_form_for, :project_item_path, to: :@view

  def initialize(view, data)
    @view = view
    @data = data
  end

  def as_json(options = {})
    {
      queryRecordCount: @data.count,
      totalRecordCount: @data.count,
      records: data
    }
  end

private

  def data
    items.map do |item|
      form = simple_form_for(Photo.new(item_id: item.id)) { |f|
        a = "<div class='fileUpload'>";
        a+=f.input :item_id, as: :hidden
        a+="<span class='ink-button half-horizontal-space'>Upload</span>"
        a+=f.file_field :image, :class => 'upload'
        a+=f.submit value: 'Save', :class => 'ink-button'
        a+="</div>"
        a.html_safe
      }
      {
        "name" => item.name,
        "point" => item.nice_point,
        "photos" => item.photos.count,
        "actions" => (item.photos.count > 0 ? link_to('View', project_item_path(item.project, item), :class => 'view-image ink-button align-right', :"data-id" => item.id, :"data-project_id" => item.project.id ) : "" ),
        "upload" => form
      }
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = @data.order("#{sort_column}")
    items = items.page(page).per(per_page)
    if params[:queries].present?
      items = items.where("name like :search", search: "%#{params[:queries][:search]}%") # or category like :search
    end
    items
  end

  def page
    params[:page]
  end

  def per_page
    params[:perPage].to_i > 0 ? params[:perPage].to_i : 10
  end

  def sort_column
    columns = %w[name point]
    if params[:sorts].present? && columns.include?( params[:sorts].keys.first )
      direction = " " + sort_direction(params[:sorts].values.first)
      params[:sorts].keys.first + direction
    else
      ""
    end
  end

  def sort_direction(num = "1")
    num == "1" ? "desc" : "asc"
  end
end