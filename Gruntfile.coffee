module.exports = (grunt) ->
  try
    require('time-grunt')(grunt)
  catch error
    grunt.log.debug "time-grunt not installed"
  semver = require 'semver'
  pkg = grunt.file.readJSON 'package.json'

  # Custom tasks
  # ============================================================================
  # $ grunt live
  # Start the grunt watchers (CSS + SVG sprite)
  grunt.registerTask 'watch',  ['build', 'watch', 'svgstore']

  # $ grunt build
  # Build CSS & SVGs in their folder `/assets/css` & `/assets/images`.
  grunt.registerTask 'build', ['clean', 'postcss', 'svgstore']

  # Speed up tasks
  # ============================================================================
  [
    'grunt-contrib-clean'
    'grunt-contrib-watch'
    'grunt-contrib-copy'
    'grunt-newer'
    'grunt-postcss'
    'grunt-svgstore'
  ].forEach (npmTask) ->
    task = npmTask.replace /^grunt-(contrib-)?/, ''
    grunt.registerTask task, [], () ->
      grunt.loadNpmTasks npmTask
      grunt.task.run task


  # Loaded tasks config
  # ============================================================================
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'


    # IMAGES
    # ••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

    # $ grunt svgstore
    # --------------------------------------------------------------------------
    # Optimize & combine all the svgs in the sprite folder to one big svg sprite
    svgstore:
      options:
        prefix : 'icon-' # This will prefix each ID
        svg: # will add and override the the default xmlns="http://www.w3.org/2000/svg" attribute to the resulting SVG
          viewBox : '0 0 100 100',
          xmlns: 'http://www.w3.org/2000/svg'
          'xmlns:xlink': 'http://www.w3.org/1999/xlink'
          class: 'icons'
      default :
        files:
          'src/images/icons.svg': ['src/images/sprite/*.svg']


    # CSS
    # ••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

    # $ grunt postcss
    # --------------------------------------------------------------------------
    # Applies post-treatments on CSS files
    # Post processor used :
    # * CSSnext http://cssnext.io
    # * postcss-import https://github.com/postcss/postcss-import
    # * css-mqpacker https://github.com/hail2u/node-css-mqpacker
    postcss:
      options:
        processors: [
          require('postcss-import')({
            plugins: [
              require('stylelint')()
            ]
          })
          require('css-mqpacker')({
            sort: true
          })
          require('postcss-cssnext')({
            browsers: 'last 2 versions, > 5%'
          })
          require("postcss-reporter")({ clearMessages: true })
          require('cssnano')({
            autoprefixer: false,
            zindex: false
          })
        ]
      dev:
        src: 'src/css/style.css'
        dest: 'assets/css/hati.css'


    # Utilities
    # ••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

    # $ grunt clean
    # --------------------------------------------------------------------------
    # delete all files in generated assets folders to avoid conflicts
    clean:
      build : ['assets/css', 'assets/images']

    # $ grunt copy
    # --------------------------------------------------------------------------
    # Move what needs to be moved
    copy:
      icons:
        files: [{
          expand: true
          cwd: 'src/images'
          src: ['icons.svg']
          dest: 'partials/'
          rename: (dest, src) ->
            dest + src.replace(/\.svg$/, ".hbs")
        }]


    # $ grunt watch
    # --------------------------------------------------------------------------
    # File watchers
    watch:
      options:
        spawn: false
        files: ['src/**/*']
      css:
        files: ['src/css/**/*.css']
        tasks: ['postcss']
      svg:
        files: 'src/images/sprite/*.svg'
        tasks: ['svgstore','copy:icons']
