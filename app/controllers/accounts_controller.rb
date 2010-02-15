class AccountsController < ApplicationController
  STEPS = [:adapter, :keychain, :key, :remote]

  private

  def init_wizard
    puts "starting new wizard"
    session[:new_account] = {}
  end

  def store(step, data)
    session[:new_account][step.to_sym] = data
    pp session[:new_account]
  end

  def fetch(step)
    session[:new_account][step.to_sym]
  end

  def next_step
    next_step = (STEPS - session[:new_account].keys).first

    redirect_to :action => (next_step ? next_step : :complete)
  end

  public

  def index
    init_wizard
    next_step
  end

  def adapter
    if request.post?
      store(:adapter, params[:id])
      next_step
    end
  end

  def keychain
    if request.post?
      store(:keychain, params[:id])
      next_step
    end
  end
  
  def key
    if request.post?
      key = params[:key]

      # test key here ... 

      store(:key, key)
      next_step
    end
  end

  def remote
    if request.get?
      adapter = Adapter.find(fetch(:adapter))
      keychain = Keychain.find(fetch(:keychain))
      key = fetch(:key)

      @accounts = adapter.list(keychain.details(key))

    elsif request.post?
      store(:remote, params[:id])
      next_step
    end
  end

  def complete
    # save
    # wipe - init_wizard
    # redirect to accounts list?

    @user.accounts.create(
      :external_id => fetch(:remote),
      :keychain_id => fetch(:keychain),
      :adapter_id  => fetch(:adapter),
      :name        => "new account"
    )

    init_wizard
  end

end
