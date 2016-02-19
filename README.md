# View

The missing view layer in Ruby on Rails

## Overview

This tiny little library consists of two primary abstractions,  `View::Component` and `View::Presenter`, which
enable you to better decouple your presentation logic from your erb/haml/slim/etc templates.  It's light weight,
easy to use, and provides a clean separation of concerns by employing basic OO principles to your view layer.

## Components


Components have a single responsibility, and that is to render markup.   Component objects expose a single public 
instance method named `#display`, which returns a string of markup to be rendered to the DOM.    How that markup gets 
rendered is completely up to you.  Often times, that's as simple as rendering a partial:

### Rendering using partials

_app/components/hello.rb_
```ruby
  class Hello < View::Component
    
    def display
      render partial: 'components/hello/audience'
    end
  end

```

_app/views/components/hello/_audience.html.erb_
```erb
  <p>Hello, world!</p>
```

_app/views/hello/index.html.erb_
```erb
<%= component Hello %>
<!-- Invoke the component using the global component helper -->
```

### Rendering using `content_tag`

If you're performance conscious, or a partial seems a bit heavy for your use case, `content_tag` also works:

_app/components/hello.rb_
```ruby
  class Hello < View::Component
    
    def display
      content_tag :p, 'Hello, world!'
    end
  end
```

### Rendering with state

Components are stateful, with state being represented internally as a hash.  Values can be retrieved using
the dynamically generated instance methods, which correspond to the key name.   In the example below, we 
defined a state key called 'audience', and in the component we just call `#audience` to fetch the value.

Not all components will have state, like the one above for example, but many will. 
Typically that state is set inside the controller and shuttled down to the template using an 
instance variable.  Components are passed initial state on invocation:


_app/controllers/hello_controller.rb_
```ruby
  class Hello < ApplicationController  
    def index 
      @audience = 'world'
    end
  end
```

_app/components/hello.rb_
```ruby
  class Hello < View::Component    
    def display
      render partial: 'components/hello_world', 
             locals: { audience: audience }
    end
  end
```

_app/views/components/hello/_audience.html.erb_
```erb
  <p>Hello, <%= audience %>!</p>
```

_app/views/hello/index.html.erb_
```erb
<%= component Hello, audience: @audience %>
```

### View logic

View logic, broadly speaking, comes in two main flavors:  Conditional and presentational/formatting.   Let's focus on the former first.

#### Conditional

##### If this, then do that
Let's assume we're using Devise or something similar, and we a handle on the `current_user` and `user_signed_in?` convenience methods.
And if the user is signed in, we want to spit out 'Hello, Bob!' or whatever the user's first name is.   If not, we want to display the
default 'Hello, world!' message.  One way to do that would be:

_app/controllers/hello_controller.rb_
```ruby
  class Hello < ApplicationController  
    def hello
    end
  end
```

_app/components/hello.rb_
```ruby
  class Hello < View::Component    
    def display
      render partial: 'components/hello', 
             locals: { audience: audience }
    end

    private
    def audience
      if user_signed_in?
        current_user.first_name
      else
        audience 
      end
    end
  end
```

_app/views/components/hello/_audience.html.erb_
```erb
  <p>Hello, <%= audience %>!</p>
```

_app/views/hello/index.html.erb_
```erb
<%= component Hello, audience: 'world' %>
```

Or you could choose to render a different partial altogether based on some condition.  The implementation is up to you.   The main
idea is that conditional display logic now has a home, and isn't out on the street inside your templates.


##### Display all the Things

Displaying lists of things is a common use case, so how do we do that with components?   First, we get in the mindset that everything 
is a component. Then, we break it down our list into its component parts.   If you've worked with React before, this process will be
very familiar for you.   

Let's keep it simple and display an unordered list of Thing models.  In this scenario, we have two component types.  We have a `ThingList`
component, which is a container for `ThingItem` components.   One possible implementation might look like:

_app/controller/things_controller.rb_
```ruby
  class ThingsController < ApplicationController
    def index
      @things = Thing.all
    end
  end
```

_app/views/things/index.html_

```erb
  = component ThingList, things: @things
```


_app/components/things_list.rb_
```ruby
  class ThingList < View::Component
    def display
      content_tag :ul do
        things.each do |thing|
          component ThingItem, thing: thing
        end
      end
    end
  end
```

_app/components/thing_item.rb_
```ruby
  class ThingItem < View::Component
    def display
      content_tag :li, thing.name
    end
  end
```

_output_
```html
  <ul>
    <li>This thing</li>
    <li>That thing</li>
    <li>Other thing</li>
  </ul>
```

Here, we're invoking one component from another, effectively nesting and composing them in a hierarchy.  Components are inifinitely
nestable.

#### Presentational / Formatting

Besides conditional logic, the other concern of the view is to format data for human consumption.   For example, formatting dates/time
and number strings is a common use case.   Or sometimes you want to concatenate two values such as first name and last name.  Perhaps
you want to truncate a string.   

This is where `View::Presenter` comes in.   A Presenter is an object whose responsibility is to transform data from one format to another.
By delegating this behavior to the presenter, you avoid having this logic in your template.  By convention, `View::Component`s are 
responsible for instantiating presenters, not controllers.   `View::Component` exposes a class method called `.presenter`, which accepts a
class constant that points to a `View::Presenter` subclass.   When that method is invoked, that exposes an instance method named `#present`
that accepts a single parameter, the object to be presented, and returns an instance of the `View::Presenter` class you declared with 
`.presenter`.  This presenter instance is then passed down to the component template in place of the original object.   In the example below,
we're presenting a stripped down User model.

_schema.rb_
```ruby
  create_table 'users' do |t|
    t.string   'email',                  default: '', null: false
    t.string   'first_name'
    t.string   'last_name'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end
```
_app/models/user.rb_
```ruby
  class User < ActiveRecord::Base
  end
```
_app/controllers/users_controller.rb_
```ruby
  class UsersController < ApplicationController
    def show
      @user = User.find(params[:id])
    end
  end
```

_app/views/users/show.html.erb_
```erb
  = component UserDetail, user: @user
```

_app/components/user_detail.rb_
```ruby
  class UserDetail < View::Component

    presenter UserDetailPresenter

    def display
      render partial: 'views/components/user_detail/_detail.html.erb, 
             locals: { user: present(user) }
    end    
  end
```
_app/presenters/user_detail_presenter.rb_
```ruby
  class UserDetailPresenter < View::Presenter
    
    def name
      [ first_name, last_name ].join(' ')
    end

    def formatted_created_at
      created_at.strftime('%m/%d/%Y at %I:%M%p')
    end
  end
```

_app/views/components/user_detail/_detail.html.erb_
```erb
  <p><%= user.name %> created on <%= user.formatted_created_at %></p>
```
