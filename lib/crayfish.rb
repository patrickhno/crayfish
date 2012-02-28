# Copyright (c) 2012 Bingoentrepenøren AS
# Copyright (c) 2012 Patrick Hanevold
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'action_controller'
require 'action_view'

require 'prawn'
begin 
  require "prawn/layout"
rescue LoadError
end

require 'crayfish/action_controller'
require 'crayfish/action_view'
require 'crayfish/rails/pdf'
require 'crayfish/rails/base'
require 'crayfish/elements/container.rb'
require 'crayfish/elements/cell_helper.rb'
require 'crayfish/elements/row.rb'
require 'crayfish/elements/table.rb'
require 'crayfish/elements/form.rb'

class ActionController::Base
  include Crayfish::ActionController
end

class ActionView::Base
  include Crayfish::ActionView
end

module ActionView
  Mime::Type.register "application/pdf", :pdf
  ActionView::Template.register_template_handler 'crayfish', Crayfish::Rails::Base
end
