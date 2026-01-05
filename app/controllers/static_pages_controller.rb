class StaticPagesController < ApplicationController
  # allow_unauthenticated_access only: [:homepage, :pricing, :documentation, :playground, :about]
  skip_before_action :authenticate, only: [ :homepage, :pricing, :documentation, :playground, :about ]
  def homepage
    if user_signed_in?
      redirect_to text_to_speeches_path
    end

    @voices = Voice.includes(:languages, :user).order(id: :desc)
  end

  def dashboard
  end

  def playground
  end

  def pricing
  end

  def documentation
  end

  def about
  end
end
