# frozen_string_literal: true

# Helpers methods
module Helpers
  # Authentification
  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    !!current_user
  end

  def hash_password(password)
    BCrypt::Password.create(password).to_s
  end

  def test_password(password, hash)
    BCrypt::Password.new(hash) == password
  end

  # API
  def base_url
    url_scheme = request.env['rack.url_scheme']
    http_host = request.env['HTTP_HOST']
    @base_url ||= "#{url_scheme}://#{http_host}"
  end

  def json_params
    JSON.parse(request.body.read)
  rescue StandardError
    halt(400, { message: 'Invalid JSON' }.to_json)
  end

  def candidate
    @candidate ||= Candidate.where(guid: params[:guid]).first
  end

  def vacancy
    @vacancy ||= Vacancy.where(guid: params[:guid]).first
  end

  def candidate_not_found!
    halt(404, { message: 'Кандидата с таким GUID не существует!' }.to_json) unless candidate
  end

  def vacancy_not_found!
    halt(404, { message: 'Вакансии с таким GUID не существует!' }.to_json) unless vacancy
  end

  def serialize(candidate)
    CandidateSerializer.new(candidate).to_json
  end

  def to_json_with_filters(params, manager)
    objcts = manager.all

    %i[id guid updated_after].each do |filter| # TODO: syncid, as param to return latest changes
      objcts = objcts.send(filter, params[filter]) if params[filter]
    end

    objcts.map { |objct| CandidateSerializer.new(objct) }.to_json
  end

  def create_object(json_params, manager)
    ojct = manager.new(json_params)
    halt 422, serialize(ojct) unless ojct.save

    response.headers['Location'] = "#{base_url}/api/v1/#{ojct.id}"
    status 201
  end

  def update_object(objct, json_params)
    halt 422, serialize(objct) unless objct.update_attributes(json_params)
    serialize(objct)
  end

  # Candidate write methods
  def error(object, fldsnms)
    # object.errors.full_messages.first
    error_texts = []
    object.errors.each do |k, v|
      error_text = t("candidate.error.#{k}")
      error_text = "#{k} #{v}" unless error_text.index('translation missing:').nil?
      error_texts << error_text
      fldsnms << k
    end
    error_texts.join('<br>') unless error_texts.empty?
  end

  # fill by params
  # TODO: need refactoring(we must use: https://mongomapper.com/documentation/plugins/associations.html#many-to-many)
  def add_arrays_to_candidate(candidate, params, type, always_save)
    tables_names(type).each do |table_name, ver_fields|
      arr = []
      do_not_add = false
      params.select { |key| key == table_name }.each_value do |table|
        table.each_value do |row|
          do_not_add = do_not_add(row, ver_fields) || do_not_add
          arr << row
        end
      end
      arr = [] if do_not_add && !always_save
      candidate[table_name] = arr
    end
  end

  def do_not_add(row, ver_fields)
    do_not_add = false

    ver_fields.each do |ver_field|
      do_not_add = true if row[ver_field] == ''
    end

    do_not_add
  end

  def tables_names(type)
    if type == 'worker'
      table_names_worker
    else
      table_names_spec
    end
  end

  def table_names_worker
    {
      'relatives' => %I[name type date job adr],
      'education' => %I[inst begin end spec],
      'extra' => %I[inst year name duration],
      'experience' => %I[name period_start period_finish pos dism duties],
      'reccomenders' => %I[name]
    }
  end

  def table_names_spec
    {
      'relatives' => %I[name type date job adr],
      'education' => %I[inst begin end spec form],
      'extra' => %I[inst year name duration],
      'language' => %I[name],
      'experience' => %I[name period_start period_finish pos dism duties field workers subords],
      'reccomenders' => %I[name]
    }
  end

  # Candidate types (worker/spec)
  def get_view_for_type(view_page, type)
    if type == 'worker'
      same_pages = {
        edit: :edit_worker
      }

      page_from_type = same_pages[view_page]
      view_page = page_from_type if page_from_type
    end

    erb view_page
  end
end
