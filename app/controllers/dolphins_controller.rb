class DolphinsController < AuthenticatedController
  def index
    load_index_variables params
  end

  def create
    from = User.find_by(email: domained_email(params[:dolphin][:from]))
    ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip

    @dolphin = Dolphin.new(from: from, to: current_user, source: ip)
    if @dolphin.save
      redirect_to({action: :index}, notice: 'Dolphin was successfully created.')
    else
      flash[:alert] = @dolphin.errors[:from].first
      @dolphin.from = nil
      load_index_variables
      render :index
    end
  end

  private

  def load_index_variables params={}
    query = Dolphin.includes(:from, :to).order('created_at desc')

    if params[:filter]
      if (user = User.find_by(email: domained_email(params[:filter])))
        query = query.where('from_id=? or to_id=?', *[user.id] * 2)
      else
        flash[:alert] = "#{params[:filter]} does not match a valid email"
        params[:filter] = nil
      end
    end

    @dolphins = query.paginate(page: params[:page], per_page: 8)
    @top_froms = Dolphin.top(by: :from, limit: 8)
    @top_tos = Dolphin.top(by: :to, limit: 8)
  end

  def domained_email(email)
    if ENV["GOOGLE_CLIENT_DOMAIN"] and !email.include?('@')
      email += "@#{ENV["GOOGLE_CLIENT_DOMAIN"]}"
    end
    email
  end
end
