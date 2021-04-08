class ApplicationController < ActionController::Base
  def render_json(data, status = :ok)
    render plain: JSON.pretty_generate(data), status: status
  end
end
