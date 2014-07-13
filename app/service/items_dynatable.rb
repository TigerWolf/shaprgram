class ItemsDynatable
  delegate :params, :h, :link_to, :simple_form_for, :project_item_path, to: :@view

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
      # TODO: Move to view
      form = simple_form_for(Photo.new(item_id: item.id)) { |f|
        a = "<div class='fileUpload'>";
        a+=f.input :item_id, as: :hidden
        a+=f.file_field :image, :class => 'upload'
        a+=f.submit value: 'Save', :class => 'ink-button green'
        a+="</div>"
        a.html_safe
      }
      {
        "name" => item.name,
        "point" => "<i class='fa fa-globe tooltip' title='#{item.nice_point}'></i>",
        "photos" => item.photos.count,
        "actions" => link_to('View', project_item_path(item.project, item), :class => 'view-image ink-button align-right blue', :"data-id" => item.id, :"data-project_id" => item.project.id ) ,
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
      items = items.where("name like :search", search: "%#{params[:queries][:search]}%")
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
    # 1 for desc, -1 for asc and other value.
    num == "1" ? "desc" : "asc"
  end
end