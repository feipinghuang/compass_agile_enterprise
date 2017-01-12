require 'fileutils'

namespace :knitkit do
  namespace :website do

    desc 'Import Knitkit website'
    task :import, [:website_iid, :username, :export_path] => :environment do |t, args|
      website = Website.find_by_internal_identifier(args[:website_iid])
      user = User.find_by_username(args[:username])

      if !website and user

        puts 'Starting Import...'
        file = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.open(args[:export_path]),
          filename: File.basename(args[:export_path])
        )
        Website.import(file, user)
        puts 'Import Complete'

      else
        puts "Website already exists, please delete first" if website
        puts "Could not find user" unless user
      end
    end

    desc 'Export knitkit website'
    task :export, [:website_iid, :export_path] => :environment do |t, args|
      website = Website.find_by_internal_identifier(args[:website_iid])

      if website

        puts 'Starting Export...'

        path = website.export
        FileUtils.mv(path, args[:export_path])

        puts 'Export Complete'

      else
        puts "Could not find website"
      end
    end

    desc 'Insert components for knitkit website'
    task :insert_components => :environment do |t, args|
      COMPONENTS = [ { id: 'header2',
                       type: 'header',
                       thumbnail: '/website_builder/header2.png',
                       height: 581,
                       url: '/website_builder/header2.html',
                       body_html:  '<div id="page" class="page"><div class="item header padding-bottom-0" id="header2">  <div class="wrapper"> <div class="container"> <nav role="navigation" class="navbar plain margin-top-20">    <div class="navbar-header"><button data-target="#navbar-collapse-02" data-toggle="collapse" class="navbar-toggle" type="button"><span class="sr-only">Toggle navigation</span> </button><a href="#" class="navbar-brand editContent" data-selector="nav a"><img alt="" src="website_builder/images/icons/brush.svg" style="height: 45px; outline: none; cursor: inherit;" data-selector="img"> HTML Builder</a></div><div id="navbar-collapse-02" class="collapse navbar-collapse"> <ul class="nav navbar-nav navbar-right">  <li class="active propClone"><a href="#" class="editContent" data-selector="nav a" style="outline: none; cursor: inherit;">Home</a></li> <li class="propClone"><a href="#"  class="editContent" data-selector="nav a" style="outline: none; cursor: inherit;">Work</a></li><li class="propClone"><a href="#"  class="editContent" data-selector="nav a" style="outline: none; cursor: inherit;">Blog</a></li><li class="propClone"><a href="#"  class="editContent" data-selector="nav a" style="outline: none; cursor: inherit;">Contact</a></li> </ul> </div><!-- /.navbar-collapse -->  </nav></div><!-- /.container -->   </div><!-- /.wrpaper -->   <header class="wrapper grey"> <div class="container">  <div class="row banner2"><div class="col-md-7"> <h1 class="editContent" data-selector=".editContent" style="">Vestibulum pellentesque nunc ac porta</h1> <p class="editContent" data-selector=".editContent" style="outline: none; cursor: inherit;"> Proin ullamcorper non neque nec lacinia. Praesent sodales libero accumsan pulvinar tempus. Proin nec lacus enim. Vivamus ullamcorper iaculis arcu et semper. Nulla venenatis nibh sed ligula placerat bibendum. Suspendisse malesuada enim eget elit congue rutrum.</p> <a href="#" class="btn btn-primary btn-embossed btn-wide editContent" data-selector="a.btn, button.btn" style=""><span class="fa fa-arrow-circle-o-right editContent" data-selector="span.fa" style="outline: none; cursor: inherit;"></span> Learn more</a> </div>  </div><!-- /.row --></div><!-- /.container -->   </header></div><!-- /.wrapper --><!-- /.item --> </div>'},
                     { id: 'header6',
                       type: 'header',
                       thumbnail: '/website_builder/header6.png',
                       height: 465,
                       url: '/website_builder/header6.html',
                       body_html: '<div id="page" class="page"><header class="item header margin-top-0 padding-bottom-0" id="header6">  <div class="wrapper">      <div class="container"> <nav role="navigation" class="navbar navbar-inverse navbar-embossed navbar-fixed-top"><div class="container"><div class="navbar-header"><button data-target="#navbar-collapse-02" data-toggle="collapse" class="navbar-toggle" type="button">  <span class="sr-only">Toggle navigation</span>        </button><a href="#" class="navbar-brand brand" class="editContent" data-selector="nav a" style="outline: none; cursor: inherit;"> HTML Builder</a>        </div>       <div id="navbar-collapse-02" class="collapse navbar-collapse"><ul class="nav navbar-nav">   <li class="active propClone"><a href="#" class="editContent" data-selector="nav a" style="outline: none; cursor: inherit;">Home</a></li> <li class="propClone"><a href="#" class="editContent" data-selector="nav a" style="outline: none; cursor: inherit;">Work</a></li>  <li class="propClone"><a href="#" class="editContent" data-selector="nav a" style="outline: none; cursor: inherit;">Blog</a></li>  <li class="propClone"><a href="#" class="editContent" data-selector="nav a">Contact</a></li></ul> <ul class="nav navbar-nav navbar-right"> <li class="propClone">   <a href="#" class="editContent" data-selector="nav a" style="outline: none; cursor: inherit;">Login <span class="fa fa-lock editContent" data-selector="span.fa" style="outline: none; cursor: inherit;"></span></a> </li></ul></div><!-- /.navbar-collapse --></div><!-- /.container --></nav>  <div class="row banner">      <div class="col-md-10 col-md-offset-1">  <div id="myCarousel" class="carousel carousel1 slide margin-top-80 margin-bottom-80" data-interval="false">  <!-- Wrapper for slides -->  <div class="carousel-inner">   <div class="item active text-center"><h1 class="editContent" data-selector=".editContent">Proin aliquet luctus magna at convallis.</h1><p class="lead editContent" data-selector=".editContent"> Phasellus aliquet velit sit amet ex egestas posuere. Interdum et malesuada fames ac ante ipsum primis in faucibus. Duis eu scelerisque diam. Praesent nunc justo, sagittis ac aliquam nec, dictum at enim.</p><p class="text-center"> <a href="#" class="btn btn-default btn-embossed btn-wide editContent" data-selector="a.btn, button.btn" style="outline: none; cursor: inherit;"><span class="fa fa-arrow-right editContent" data-selector="span.fa" style="outline: none; cursor: inherit;"></span> &nbsp;Go Somewhere...</a></p>   </div>   <div class="item text-center">       <h1 class="editContent" data-selector=".editContent" style="outline: none; cursor: inherit;">Proin aliquet luctus magna at convallis.</h1><p class="lead editContent" data-selector=".editContent" style="outline: none; cursor: inherit;"> Phasellus aliquet velit sit amet ex egestas posuere. Interdum et malesuada fames ac ante ipsum primis in faucibus. Duis eu scelerisque diam. Praesent nunc justo, sagittis ac aliquam nec, dictum at enim.       </p>       <p class="text-center"> <a href="#" class="btn btn-info btn-embossed btn-wide editContent" data-selector="a.btn, button.btn" style="outline: none; cursor: inherit;"><span class="fa fa-cab editContent" data-selector="span.fa" style="outline: none; cursor: inherit;"></span> &nbsp;Do Something...</a></p>   </div>   <div class="item text-center">       <h1 class="editContent" data-selector=".editContent" style="outline: none; cursor: inherit;">Proin aliquet luctus magna at convallis.</h1><p class="lead editContent" data-selector=".editContent" style="outline: none; cursor: inherit;"> Phasellus aliquet velit sit amet ex egestas posuere. Interdum et malesuada fames ac ante ipsum primis in faucibus. Duis eu scelerisque diam. Praesent nunc justo, sagittis ac aliquam nec, dictum at enim.</p><p class="text-center"> <a href="#" class="btn btn-primary btn-embossed btn-wide editContent" data-selector="a.btn, button.btn" style="outline: none; cursor: inherit;"><span class="fa fa-bullhorn editContent" data-selector="span.fa" style="outline: none; cursor: inherit;"></span>  &nbsp;Spread Joy!</a>        </p>   </div> </div> <!-- Indicators -->  <ol class="carousel-indicators">   <li data-target="#myCarousel" data-slide-to="0" class="active"></li>   <li data-target="#myCarousel" data-slide-to="1"></li>    <li data-target="#myCarousel" data-slide-to="2"></li>  </ol>       </div>      </div>  </div><!-- /.row -->       </div><!-- /.container -->   </div><!-- /.wrapper --> </header><!-- /.item --></div>'},
                     {  id: 'content_section1',
                        type: 'content_section',
                        thumbnail: '/website_builder/content_section1.png',
                        height: 550,
                        url: '/website_builder/content_section1.html',
                        body_html: '<div id="page" class="page"><div class="item content" id="content_section1"><div class="container"> <div class="row"> <div class="col-md-8"><div class="editContent" data-selector=".editContent" style="outline: none; cursor: inherit;"><h3>Aenean varius lorem at dui condimentum convallis</h3> <p>Ut non lobortis est. Ut dictum scelerisque luctus. Aliquam condimentum interdum odio, et fermentum nulla pharetra in. Praesent pellentesque neque nec eros tempus, ac venenatis ante interdum. Vivamus viverra est dolor, non placerat nunc commodo sed</p></div><br><div class="row"> <div class="col-md-6"><div class="videoWrapper">   <iframe width="560" height="315" src="//www.youtube.com/embed/scy6aUCn_hs?controls=0&amp;showinfo=0" frameborder="0" allowfullscreen=""></iframe><div class="frameCover" data-type="video" data-selector=".frameCover" style="outline: none; cursor: inherit;"></div> </div></div><div class="col-md-6 editContent" data-selector=".editContent" style="outline: none; cursor: inherit;">   <h5>A Little Video</h5> <p>Can go a long way to make your content come alive! Hear hear! <a href="">Learn more</a>  </p></div></div>  </div><!-- ./col-md-8 -->   <div class="col-md-4"><br><blockquote class="editContent" data-selector=".editContent" style="outline: none; cursor: inherit;"><p>Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. </p><small>Steve Jobs, CEO Apple</small>   </blockquote> <br><a href="#" class="btn btn-primary btn-embossed btn-block margin-bottom-20 editContent" data-selector="a.btn, button.btn" style="outline: none; cursor: inherit;"><span class="fa fa-linkedin-square" data-selector="span.fa" style="outline: none; cursor: inherit;"></span> Do Something Now!</a> <a href="#" class="btn btn-default btn-embossed btn-block editContent" data-selector="a.btn, button.btn" style="outline: none; cursor: inherit;"><span class="fa fa-google-plus-square editContent" data-selector="span.fa" style="outline: none; cursor: inherit;"></span> Do Something Else Next!</a>   </div><!-- /.col-md-4 -->   </div><!-- /.row --></div><!-- /.container --></div><!-- /.item -->  </div>'},
                     { id: 'footer2',
                       type: 'footer',
                       thumbnail: '/website_builder/footer2.png',
                       height: 114,
                       url: '/website_builder/footer2.html',
                       body_html: '<div id="page" class="page"><div class="footerWrapper" id="footer2"><div class="item footer bottom-menu"><div class="container"><div class="row"><div class="col-md-2"> <a class="bottom-menu-brand" href="#fakelink" class="editContent" data-selector=".footer a" style="outline: none; cursor: inherit;"><img src="website_builder/images/icons/brush.svg" class="small" style="height: 30px; outline: none; cursor: inherit;" data-selector="img"></a> </div><div class="col-md-8"><ul class="bottom-menu-list">  <li><a href="#fakelink" class="editContent" data-selector=".footer a" style="outline: none; cursor: inherit;">About Us</a></li><li><a href="#fakelink"  class="editContent" data-selector=".footer a" style="outline: none; cursor: inherit;">Store</a></li><li class="active"><a href="#fakelink"  class="editContent"  data-selector=".footer a" style="outline: none; cursor: inherit;">Jobs</a></li><li><a href="#fakelink"  class="editContent" data-selector=".footer a" style="outline: none; cursor: inherit;">Privacy</a></li><li><a href="#fakelink"  class="editContent"  data-selector=".footer a" style="outline: none; cursor: inherit;">Terms</a></li><li><a href="#fakelink"  class="editContent"  data-selector=".footer a" style="outline: none; cursor: inherit;">Follow Us</a></li><li><a href="#fakelink"  class="editContent" data-selector=".footer a" style="outline: none; cursor: inherit;">Support</a></li><li><a href="#fakelink"  class="editContent" data-selector=".footer a" style="outline: none; cursor: inherit;">Links</a></li></ul>  </div><div class="col-md-2"><ul class="bottom-menu-iconic-list"><li><a class="fa fa-pinterest" href="#fakelink"  class="editContent" data-selector=".footer a" style="outline: none; cursor: inherit;"></a></li><li><a class="fa fa-facebook" href="#fakelink"  class="editContent" data-selector=".footer a" style="outline: none; cursor: inherit;"></a></li><li><a class="fa fa-twitter" href="#fakelink"  class="editContent" data-selector=".footer a" style="outline: none; cursor: inherit;"></a></li></ul>  </div> </div></div></div><!-- /.item --> </div><!-- /.footerWrapper --></div>' },
                     {  id: 'footer3',
                        type: 'footer',
                        thumbnail: '/website_builder/footer3.png',
                        height: 715,
                        url: '/website_builder/footer3.html',
                        body_html: '<div id="page" class="page"><div class="footerWrapper" id="footer3"> <div class="item footer dark"><div class="container"> <div class="row"> <div class="col-md-6 col-md-offset-3 text-center social"><div class="editContent" data-selector=".editContent" style="outline: none; cursor: inherit;">  <h2 class="editContent" data-selector="h1, h2, h3, h4, h5, p" style="outline: none; cursor: inherit;">We are HTML Builder!</h2> <span>We are social, come meet and meet us:</span><br></div> <a href="#" class="fa fa-facebook-square editContent" data-selector=".social a" style="outline: none; cursor: inherit;"></a> <a href="#" class="fa fa-twitter-square editContent" data-selector=".social a" style="outline: none; cursor: inherit;"></a><a href="#" class="fa fa-linkedin-square editContent" data-selector=".social a" style="outline: none; cursor: inherit;"></a> <a href="#" class="fa fa-github-square editContent" data-selector=".social a" style="outline: none; cursor: inherit;"></a> <a href="#" class="fa fa-google-plus-square editContent" data-selector=".social a" style="outline: none; cursor: inherit;"></a><a href="#" class="fa fa-pinterest-square editContent" data-selector=".social a" style="outline: none; cursor: inherit;"></a><a href="#" class="fa fa-reddit-square editContent" data-selector=".social a" style="outline: none; cursor: inherit;"></a>  </div><!-- /.col -->  </div><!-- /.row --></div></div><!-- /.item -->  </div><!-- /.footerWrapper -->  </div>'}]

      Component.destroy_all
      COMPONENTS.each do |component|
        unless Component.where(internal_identifier: "#{component[:id]}").first
          Component.create!({
                              title: component[:type].downcase.camelcase,
                              body_html: component[:body_html],
                              internal_identifier: "#{component[:id]}",
                              custom_data: { thumbnail: component[:thumbnail],
                                             url: component[:url],
                                             height: component[:height],
                                             component_type: component[:type].downcase }
          })
        end ## unless block
      end ## Component array loop
    end ## Component insert rake task
  end

  namespace :theme do

    desc 'Import Knitkit theme'
    task :import, [:website_iid, :export_path] => :environment do |t, args|
      website = Website.find_by_internal_identifier(args[:website_iid])

      if website

        puts 'Starting Import...'
        file = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.open(args[:export_path]),
          filename: File.basename(args[:export_path])
        )
        Theme.import(file, website)
        puts 'Import Complete'

      else
        puts "Website doesn't exists"
      end
    end

    desc 'Export knitkit theme'
    task :export, [:website_iid, :theme_id, :export_path] => :environment do |t, args|
      website = Website.find_by_internal_identifier(args[:website_iid])
      theme = website.themes.find_by_theme_id(args[:theme_id])

      if website && theme

        puts 'Starting Export...'

        path = theme.export
        FileUtils.mv(path, args[:export_path])

        puts 'Export Complete'

      else
        puts "Could not find website" unless website
        puts "Could not find theme" unless theme
      end
    end

  end
end
