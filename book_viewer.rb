require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

helpers do
  def in_paragraphs(chapter_content)
    chapter_content.split(/"\n\n"/).map.with_index do |line, index|
      "<p id='<%=  %>'>#{line}</p>"
    end.join
  end
end

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number- 1]
  @title = "Chapter #{number}: #{chapter_name}"

  @chapter = File.read("data/chp#{number}.txt")
  erb :chapter
end

get "/show/:name" do
  params[:name]
end

# Calls the block for each chapter, passing that chapter's number, name, and
# contents.
def each_chapter(&block)
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    results << {number: number, name: name} if contents.include?(query)
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

not_found do
  redirect "/"
end
