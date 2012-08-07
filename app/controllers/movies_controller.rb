class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def session_def(var, sess, key)
#p 'session_def'
#p var[key]
#p sess[key]
    if var[key] == nil && sess[key] != nil
#p 'setting'
      var[key] = sess[key]
    end
  end

  def index

p '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
    # check for clearing sorting and filtering
    if params[:reset] != nil then

      # clear out everything and refresh page
      session.clear
      params.clear

      redirect_to movies_path

    else

      # make sure URI always represents current state for filtering
      @ratings = ""
      if params[:ratings] == nil && session[:ratings] != nil then
p "44444 "
p session[:ratings]
        session[:ratings].each_key { |rating| p rating }
@a = Array.new
        session[:ratings].each_key { |rating| @a.push rating }
p "55555"
p @a
        @a.each { |rating| @ratings = @ratings + "&ratings[" + rating + "]=1" }
  p '##############################'
  p "RATINGS>> becomes "
  p @ratings
  p '=============================='
      end

      # make sure URI always represents current state for sorting
      @sort = ""
      if params[:sort] == nil && session[:sort] != nil then
        @sort = "sort=#{session[:sort]}"
  p '------------------------------'
  p "SORT>> " + session[:sort] + " becomes " + @sort
  p '=============================='
      end

      # redirect to ensure a RESTful URI if needed
      if @sort.length > 0 && @ratings.length == 0 then
p '************************************************************************'
p "-------->>>> #{movies_path}?#{@sort}"
p '************************************************************************'
        redirect_to movies_path + "?#{@sort}"
      elsif @ratings.length > 0 && @sort.length == 0 then
        @ratings = @ratings.gsub(/^&/, '')
p '************************************************************************'
p "-------->>>> #{movies_path}?#{@ratings}"
p '************************************************************************'
        redirect_to movies_path + "?#{@ratings}"
      elsif @ratings.length > 0 && @sort.length > 0 then
p '************************************************************************'
p "-------->>>> #{movies_path}?#{@sort}#{@ratings}"
p '************************************************************************'
        redirect_to movies_path + "?#{@sort}#{@ratings}"
      else

        # find unique ratings already in the database
        @all_ratings = Movie.find(:all, :select => "distinct rating", :order => :rating).collect { |movie| movie.rating }

        # prepare checked states for each rating
        @checks = Hash.new
        @all_ratings.each { |rating| @checks.store(rating, false) }

        # ^^^ ideally the sort functionality would protect against xss attacks via URL parameter
        # ^^^ move into method of Movie

        # default to session values if they're missing
        session_def(params, session, :sort)
        session_def(params, session, :ratings)

        if params[:sort] == nil then
          @order = "id"
        else
          @order = params[:sort]
        end

        if params[:ratings] == nil then
          @conditions = "1 = 1"
        else
          @conditions = "rating in ("
          params[:ratings].each_key { |rating|
            @conditions = @conditions + "'" + rating + "',"
            @checks[rating] = true
          }
          @conditions = @conditions + "'-')"
        end

        # save session values for next iteration
        session[:sort] = params[:sort]
        session[:ratings] = params[:ratings]

        # select the movies constrained by sorting and filtering
        @movies = Movie.find(:all, :order => @order, :conditions => @conditions)

      end

    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
