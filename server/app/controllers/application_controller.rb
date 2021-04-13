class ApplicationController < ActionController::Base
  LIMIT = 12

  def render_json(data, status = :ok)
    render plain: JSON.pretty_generate(data), status: status
  end

  def paginate(record = resources, page = params[:page], limit = params[:limit])
    limit ||= LIMIT
    limit = limit.to_i

    offset = (page.to_i - 1) * LIMIT
    offset = 0 if offset.negative?

    record.limit(limit).offset(offset)
  end

  def metadata
    count = resources.count
    {
      page_count: (count / LIMIT.to_f).ceil,
      resource_count: count
    }
  end

  def resources
    raise 'Define a resource'
  end
end
