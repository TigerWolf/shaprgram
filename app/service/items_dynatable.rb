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
        a = ""
        a+=f.input :item_id, as: :hidden
        a+=f.file_field :image
        a+=f.submit value: 'Save'
        a.html_safe
      }
      {
        "name" => item.name,
        "point" => item.point,
        "photos" => item.photos.count,
        "actions" => link_to('View', project_item_path(item.project, item) ),
        "upload" => form
      }
    end
  end

  def items
    @items ||= fetch_items
  end

  def fetch_items
    items = @data.order("#{sort_column} #{sort_direction}")
    items = items.page(page).per(per_page)
    if params[:queries].present?
      items = items.where("name like :search", search: "%#{params[:queries][:search]}%") # or category like :search
    end
    items
  end

  def page
    params[:page] #.to_i/per_page + 1
  end

  def per_page
    params[:perPage].to_i > 0 ? params[:perPage].to_i : 10
  end

  def sort_column
    columns = %w[name]
    columns.first
    #columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    nil == "desc" ? "desc" : "asc"
  end
end