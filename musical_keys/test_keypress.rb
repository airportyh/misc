content = 'Type any key.'
Shoes.app do
  @info = para "Type any key."
  keypress do |k|
    content += "\n#{k.inspect} was pressed."
    @info.replace(content)
  end
end