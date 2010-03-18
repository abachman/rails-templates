# What's up with the Template?

## Goals

Smartlogic Solutions Rails-app-in-a-box.

## Methods

Rails Application Template files are all in the root of the project directory.
`template.rb` is the main file, it calls the others as needed. Most of the
other template files load external files into the new project. Those files are
contained in the child directories under the root of this project.

The application creation process works roughly like this:

1. load `environment.rb` - setup the environment (based on jtrupiano's environmentalist gem).
2. load some standard gems and plugins
3. `capify!` if needed
4. clean up the project directory and do a git checkin.
5. load `authentication.rb` - setup authlogic and the requisite models, views, and controllers
6. load `haml.rb` - setup compass and haml for content rendering.
7. load `javascript.rb` - setup jammit for javascript asset management.
8. save the geminstaller.yml files (see **Application Notes** below)
9. load `start.rb` - setup a start controller so you've got something to work with.
10. setup default factory and some rake tasks to make seeding development data easy
11. load `test.rb` - setup the testing environment and generate the initial tests.
12. create and migrate the database.

## Using the Template

    rails -m http://github.com/smartlogic/rails-templates/raw/master/template.rb $PROJECT_NAME

That's it.

From here you should be able to start the built in server or edit and link
config/development/apache.conf into your passenger .conf dir and run the application.

Tests should also run out of the box.

To run the template from a local directory (working copy), add the `LOCAL=true`
env argument and reference `template.rb` locally. For example:

    LOCAL=true rails -m rails-templates/template.rb $PROJECT_NAME

## Application Notes

You'll notice we don't use the normal `gem` command, since we use geminstaller
on our projects. If you need to add a gem to the template, use the form
`geminstaller '$GEMNAME'` instead of `gem '$GEMNAME'`. If it's a gem that's
only needed in one environment (e.g., "test"), call `geminstaller '$GEMNAME',
:test`.

Make sure all your calls to `geminstaller` come before `@geminstaller.save`,
that's when the geminstaller.yml files are written.


