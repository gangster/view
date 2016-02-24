# View

Because your Rails views suck and you don't know what to do about it.

## Purpose

It's the most common thing in the world to see shitty ass Rails templates.  And by shitty, I mean:

...You can't fucking find the template you need   
...and when you do find it, the fucker is hundreds of lines long    
...with confusing conditional statements with something like, 10 goddamned if/else branches    
...calling helper methods coming from who the hell knows where    
...and those helper methods are calling other helper methods    
...meanwhile there's @instance variables every goddamn where you look    
...and why exactly are we rendering a collection of 1000 partials here again?    
...and oh shit, each one of these partials include other partials?   
...fucking kill me now.    

And really, the above list barely scratches the surface.  Developers never fail to come up with new
and shameful ways to make their views unmaintainable and painful to work with.

But as Rails developers, it's not our fault.  Well, kind of, but it's just easier to blame the
view architecture Rails ships with, and the conventions it pushes us to follow.  Conventions
that encourage using conditional logic in views, for example.   Or using global helper methods for
any reason whatsoever, being another example.   Need to call a method on an ActiveRecord object and fire off a
database call?  Rails invites your dumb ass to do exactly that.  But by doing so, you violate dozen and one
principles of good object-oriented design, and end up fucking yourself as your application changes and grows.

This gem here is to help you stop fucking yourself.   It does this by giving you two useful abstractions for
organizing your code:  `View::Component` and `View::Presenter`, and they're easy as fuck to use, and I hope
you'll use them.

### Guidelines & Objectives

It's generally a good idea to follow [Sandi Metz' Rules For Developers](https://robots.thoughtbot.com/sandi-metz-rules-for-developers)
when building components and presenters:

#### Guidelines
- Methods less than 5 lines
- Classes less than 100 lines
- Only instantiate one object in the controller / One instance variable in view
- Four method arguments
 
Additionally, components and presenters should:

#### Objectives
- DRY
- Easy to test
- Clarity
- Easy to find
- Easy to change

## Example Application

To see examples of components in action, check out the example Rails app at 
[http://github.com/gangster/view_demo](http://github.com/gangster/view_demo)

## Components

### Overview

Components are the building blocks for your views.  Another way to look at components is as object-oriented
helpers for your views.  They have one responsibility and that's to generate markup.  Components should be small, 
focused, and have an expressive name that clearly describes what part of the view it's responsible for rendering.

### The Basics

Defining a component is as simple as extending the `View::Component` class  and implementing the `html`
method.   This method must return a string (or an array of strings, more on that later) of markup.  
Here's a simple example:

_app/components/fuck_yeah.rb_
```ruby
  class FuckYeah < View::Component
    def html
      content_tag :strong, class: 'blink red' do
        link_to 'Fuck yeah, Components', '#'
      end
    end
  end
```
Components can be invoked from inside your vanilla Rails views using a...wait for it...a global helper method.  I
promise it's the only global helper in this bitch.

_app/views/demo/index.html_ (or whatever)
```erb
<%= component FuckYeah %>
```
_Output:_
```html
<strong class="blink red">
  <a href="#">Fuck yeah, components!</a>
</strong>

```
In the example above, the `content_tag` and `link_to` helpers are used to generate the HTML.   In addition to these helpers,
pretty much every other rails helper you could possibly want is at your disposal, including helpers that depend on the request
context being available, such as URL helpers and some Devise helpers.  But the star of the show is the `render` helper, which will 
allow you to render erb/haml/slim/whatever templates.  Calling `render` inside of a component returns a string, instead of writing 
directly to the output buffer, and we can exploit that behavior to express our markup as templates instead of ruby code.

Something like this will be very common in your components:

_app/components/fuck_yeah.rb_
```ruby
  class FuckYeah < View::Component
    def html
      render 'components/fuck_yeah/index'
    end
  end
```

_app/views/components/fuck_yeah/index.html_ (or whatever)

```erb
<strong class="blink red">
  <%= link_to "Fuck yeah, components!", "#" %>
</strong>

```

It's your choice.  There are cases where using `content_tag` and friends make sense, and others where rending templates is
a better option.  Hell, if you wanted to concatenate strings and return that, then by all means, be the asshole and do that.

### Component state

Components are stateful.  State is represented as a hash, and you pass that hash to the component when you invoke it.   In most cases,
state will contain references to the instance variables containing your models and what have you.  Another case would include things like
the value of `user_signed_in?` if you're using a gem like devise, and your component needs to know whether the user is signed in or not.

Let's refactor the `FuckYeah` component to render a value we pass in through state instead of a static message.  First, let's take a look
at what that looks like when we're rendering templates.

_app/components/fuck_yeah.rb_
```ruby
  class FuckYeah < View::Component
    def html
      render 'components/fuck_yeah/index'
    end
  end
```
Haha jk lol.  No refactoring needed in the component class.  Below we're passing in a static value, but it could just as easily be an 
instance variable shat out by your controller.

_app/views/demo/index.html_
```erb
<%= component FuckYeah, what: 'burritos' %>
```

And update the template to use the `what` variable.

_app/views/components/fuck_yeah/index.html_ (or whatever)

```erb
<strong class="blink red">
  <%= link_to "Fuck yeah, #{what}!", "#" %>
</strong>

```

_Voilà:_
```html
<strong class="blink red">
  <a href="#">Fuck yeah, burritos!</a>
</strong>

``` 

And here's how the `content_tag` implementation would go.

```ruby
  class FuckYeah < View::Component
    def html
      content_tag :strong, class: 'blink red' do
        link_to "Fuck yeah, #{what}!", '#'
      end
    end
  end
```

Fuck yeah, indeed.   Note, you never access the state hash directly.   In the case of templates,
the state is passed down as locals for you automatically.  Inside of the component, state keys are
converted to accessor methods which return their corresponding values.  

If the component is rendering a template and you need to pass additional values down, simply pass
a `locals` hash to `render`:

_app/components/fuck_yeah.rb_
```ruby
  class FuckYeah < View::Component
    def html
      render 'components/fuck_yeah/index', locals: { expletive: random_expletive }
    end

    def random_expletive
      %w(Fuck Shit Hell Bleep).sample
    end
  end
```

```erb
<strong class="blink red">
  <%= link_to "#{expletive} yeah, #{what}!", "#" %>
</strong>

```

Sometimes you'll want to override a state value that you initially passed in.  You can do that
by overwriting the state in the locals hash, as values in locals take precedence over values in
state.  

_app/components/fuck_yeah.rb_
```ruby
  class FuckYeah < View::Component
    def html
      render 'components/fuck_yeah/index', locals: { expletive: 'Bleep', what: 'Tacos' }
    end
  end
```

_app/views/components/fuck_yeah/index.html_
```erb
<strong class="blink red">
  <%= link_to "#{expletive} yeah, #{what}!", "#" %>
</strong>

```

_app/views/demo/index.html_
```erb
<%= component FuckYeah, what: 'Burritos' %>
```

_Output:_
```html
<strong class="blink red">
  <a href="#">Bleep yeah, Tacos!</a>
</strong>

```

### Conditionals

Eventually you'll want to conditionally display one thing or the other based on some value in the state, or some value computed
inside of your component.   For example, if the user is signed in, we display their name and link it to their profile.  
If not, we display a sign in link.

_app/components/sign_in.rb_
```ruby
  class SignInLink < View::Component
    def html
      if user_signed_in
        link_to user.name, user_path(user)
      else
        link_to 'Sign in', new_user_session_path
      end
    end
  end
```

_app/components/sign_in/link.html.erb_
```erb
  <%= component SignIn, user: current_user, user_signed_in: user_signed_in? %>
```

It doesn't get much simpler than that.   You could go buckwild with conditionals and throw a giant ass switch statement
in there, and render a different template for each case, if you wanted to be an asshole about it.   However, well-designed
components will be small, focused, easy to understand, with minimal conditional logic.   

### Rendering Collections in Components

One of the most common tasks in the world in an application is to display collections of objects.   Traditionally, you'd just
`each` over the collection in your template and make subsequent bad decisions from there.   With components, you can implement
iteration logic any number of ways.  One such way is to break down the list view into a set of components, each responsible for 
building a different part of the view.  

_app/components/bad_ideas_list.rb_
```ruby
class BadIdeasList < View::Component
  def html
    content_tag :ul do
      component BadIdeaItems, bad_ideas: bad_ideas
    end
  end

  private

  def bad_ideas
    [ 
      OpenStruct.new(title: 'Iterating in templates'),
      OpenStruct.new(title: 'Conditional logic in templates'),
      OpenStruct.new(title: 'Formatting data in templates'),
    ]
  end
end
```

_app/components/bad_idea_items.rb_
```ruby
class BadIdeaItems < View::Component
  def html
    # use map instead of each, because the html method must
    # return a value.  In this case, an array of strings
    # containing markup, which will eventually have a 
    # #safe_join applied to it inside of #display.
    bad_ideas.map do |bad_idea|
      component BadIdeaItem, bad_idea: bad_idea
    end    
  end
end
```

_app/components/bad_idea_item.rb_
```ruby
class BadIdeaItem < View::Component
  def html
    content_tag :li, bad_idea.title
  end
end
```

_Output_
```html
<ul>
  <li>Iterating in templates</li>
  <li>Conditional logic in templates</li>
  <li>Formatting data in templates</li>
</ul>

```

Is this approach more verbose than simply `each`ing over the collection inside of the template?  Maybe.  It's definitely
a lot more reusable and expressive in my view (pun intended).   

You'll notice in the `BadIdeaItems` component, that we're returning an array of strings via the `map` call.   This is all
good because `View::Component#display` will [safe_join](http://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-safe_join) 
the string array into a single concatenated string, which is what gets rendered to the DOM.   

### The `component` helper

Globals helper methods in Rails get a bad rap, and for good reason.  Check the resources section for links to blog articles
explaining why this is so.   Nonetheless, there are legitimate uses for them, such as proxy methods, which is exactly what
our little `component` method is.   And it's really simple, let's take a look at the implementation:

```ruby
def component(component_class, state = {})
  state.merge!({ request: request })
  component_class.new(state).display
end
```

As you can see, the first thing we do is merge the request object into the state.   This serves two purposes.  First, it makes
the request context available to helpers that need it, such as URL helpers, devise helpers, etc.  And if your component needs
it for any reason, it can be accessed by calling `#request` inside of your component, which can be helpful if you're doing
some ninja shit you probably shouldn't be doing.  

Then, all we do is instantiate the component class, pass it the state, and then call display to render the HTML to the DOM and
that's it.   Knowing that, one could also invoke a component like:

```erb
  <%= FuckYeah.new(what: 'Enchiladas', request: request).display %>
```

and achieve the same results.  How you invoke components is up to you, but if you can stomach using the helper, that is the
preferred way and will be more future-proof should the component's API change in future versions.

## Presenters

### Overview

Components are only half the story, because in addition to generating markup, often times you need to transform data into a human-readable format.
Date and number formatting are common cases, as is truncating strings and joining an array of strings.   Operations like these are a separate
and distinct concern from generating markup, and thus are handled using a different type of object, `View::Presenter`.

### Presenter basics

### Defining Presenters

Creating a presenter begins with subclassing `View::Presenter`.

_app/presenters/post_presenter.rb_
```ruby
class PostPresenter < View::Presenter
end
```

Simple enough, but not altogether interesting or useful.   Let's format the created_at timestamp to be a little more human-readable.  By default,
that timestamp looks something like `Sun, 21 Feb 2016 17:25:28 UTC +00:00`, and what we want is something more like `5 minutes ago`, which we can
accomplish by using the `time_ago_in_words` helper that Rails provides.   We can do that by adding a method called `formatted_created_at` to the 
presenter which handles that for us.

_app/presenters/post_presenter.rb_
```ruby
class PostPresenter < View::Presenter
  def formatted_created_at
    time_ago_in_words(created_at)
  end
end
```
Notice that we called the `created_at` method without a receiver.   That's because any methods that don't exist on the presenter get automatically 
delegated to the object being presented.  If implicit receivers both you, or you didn't want to prefix your method name with `formatted_`, this also
works:

_app/presenters/post_presenter.rb_
```ruby
class PostPresenter < View::Presenter
  def created_at
    time_ago_in_words(presented.created_at)
  end
end
```

### Instantiating Presenters

To instantiate a presenter, just pass in the object you want to present into the constructor.   Note, that the constructor only accepts a single
argument, but the object in that argument can be whatever you want.  More often than not, it'll be an ActiveRecord object or collection of objects.

```ruby
  @post = Post.find(1)
  PostPresenter.new(post)

```

## Resources / Links

#### Blogs / Videos
- [Sandi Metz' Rules For Developers](https://robots.thoughtbot.com/sandi-metz-rules-for-developers)
- [Thoughts about Rails Presenters](https://gist.github.com/somebox/5a7ebf56e3236372eec4)
- [Presenters from Scratch Railscast](http://railscasts.com/episodes/287-presenters-from-scratch?autoplay=true)
- [Rails: Presenter Pattern by Jay Fields](http://blog.jayfields.com/2007/03/rails-presenter-pattern.html)
- [Rails Presenters: filling the Model-View-Controller gap](http://www.inspire.nl/blog/rails-presenters-filling-the-model-view-controller-gap/)
- [What I dislike about Draper](http://thepugautomatic.com/2014/03/draper/)
- [Rails Misapprehensions: Helpers are shit.](http://nicksda.apotomo.de/2011/10/rails-misapprehensions-helpers-are-shit/)
- [Decorators on Rails](http://johnotander.com/rails/2014/03/07/decorators-on-rails/)
- [RailsConf 2014 - Concerns, Decorators, Presenters, Service Objects, Helpers, Help Me Decide!](https://www.youtube.com/watch?v=bHpVdOzrvkE)
- [Better Ruby Presenters](http://blog.steveklabnik.com/posts/2011-09-09-better-ruby-presenters)
- [Decorators Compared To Strategies, Composites, and Presenters](https://robots.thoughtbot.com/decorators-compared-to-strategies-composites-and)
- [Exhibit vs Presenter](http://mikepackdev.com/blog_posts/31-exhibit-vs-presenter)

#### Prior Art
- [Draper](https://github.com/drapergem/draper)
- [Cells](http://github.com/apotonick/cells)
- [ActivePresenter](https://github.com/jamesgolick/active_presenter)
- [ActionPresenter](https://github.com/zlw/action_presenter)
- [etc](https://www.ruby-toolbox.com/categories/rails_presenters)

### WORK IN PROGRESS.  MORE TO COME ###

