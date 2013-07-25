require 'interactive_editor'
require 'set'


class << self
  def vim(name=nil)
    vim_path = '/Applications/MacVim.app/Contents/MacOS/Vim'
    vim_path = 'vim' unless File.exists? vim_path

    InteractiveEditor.edit(vim_path, name)
  end

  def pm(obj, filter=true)
    methods = Set.new obj.public_methods
    if filter
      base_methods = Set.new Object.new.public_methods
      methods -= base_methods
    end

    return methods.sort
  end
end
