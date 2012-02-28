# Crayfish

PDF templating for Rails.

Example (say app/views/main/show.pdf.crayfish):

``` ruby
<%
@location = { :name => 'GitHub', :zip_code => '0000', :city => 'Internet' }

form %Q{
  Apples %c{    }x%c{    } boxes                                | =%c{         }
  Pears %c{       }+ bananas%c{       }                         | =%c{         }
}, :title => 'Sold                                                 in kjosk %c{      }'

move_down 6
%>

<% form do |f| %>
  <% f.heading 'Sold          in kjosk '+f.field('      ') %>
  Apples   <%= f.field('    ') %>x<%= f.field('    ') %> boxes      <%= f.span %> =<%= f.field('         ') %>
  Pears <%= f.field('       ') %>+ bananas<%= f.field('       ') %> <%= f.span %> =<%= f.field('         ') %>
<% end -%>

<% table do |f| %>
  <% f.field :label => 'Repport (dd.mm.YYYY)', :value => Date.today %>
<% end -%>

<% table do |t| %>
  <% t.row do |r| %>
    <% r.label 'Permit'; r.span; r.text '    ' %>
    <% r.field :label => 'Time', :value => '    ' %>
  <% end -%>
  <% t.row do |r| %>
    <% r.label 'Cash';  r.span; r.text '    ' %>
  <% end -%>
  <% t.row do |r| %>
    <% r.label 'Organizer';          r.span; r.text 'Crayfish' %>
  <% end -%>
  <% t.row_for @location do |r| %>
    <% r.field :label => 'Location' , :value => @location[:name] %>
    <% r.field :zip_code %>
    <% r.field :city %>
  <% end -%>
<% end -%>

<% form do |f| %>
  <% f.row do |r| %>
    <% r.label 'Permit'; r.span; r.text '    ' %>
    <% r.field :label => 'Time', :value => '    ' %>
  <% end -%>
  <% f.row do |r| %>
    <% r.label 'Cash';  r.span; r.text '    ' %>
  <% end -%>
  <% f.row do |r| %>
    <% r.label 'Organizer';          r.span; r.text 'Crayfish' %>
  <% end -%>
  <% f.row_for @location do |r| %>
    <% r.field :label => 'Location' , :value => @location[:name] %>
    <% r.field :zip_code %>
    <% r.field :city %>
  <% end -%>
<% end -%>
```

Which gives:

![](http://github.com/patrickhno/crayfish/raw/master/doc/example.png) 

You could also use Prawn directly if you want to:

``` Ruby
<% table [
  [
    { :content => 'Permit', :background_color => color},
    make_table([['                ', { :content => 'Time', :background_color => color}]])],
  [{ :content => 'Cash',               :background_color => color},  ''],
  [{ :content => 'Organizer',          :background_color => color}, 'Crayfish'],
  [ { :content => make_table([
    [
      { :content => 'Location',  :background_color => color}, location[:name],
      { :content => 'Zip Code',  :background_color => color}, location[:zip_code],
      { :content => 'City',      :background_color => color}, location[:city]]
    ]), :colspan => 2
    }
  ]
], :width => 540
%>
```

## License

(The MIT License)

Copyright (c) 2012 Bingoentrepenøren AS  
Copyright (c) 2012 Patrick Hanevold

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
