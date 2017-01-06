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
      COMPONENTS = [ { id: 'header1',
                                       type: 'header',
                                       thumbnail: '/website_builder/header1.png',
                                       height: 530,
                                       url: '/website_builder/header1.html',
                                       body_html:  '<div id="page" class="page"><header class="item header padding-top-20" id="header1"><div class="wrapper"><div class="container"><nav role="navigation" class="navbar navbar-inverse navbar-embossed navbar-lg"><div class="navbar-header">  <button data-target="#navbar-collapse-02" data-toggle="collapse" class="navbar-toggle" type="button">    <span class="sr-only">Toggle navigation</span>  </button>  <a href="#" class="navbar-brand brand"> HTML Builder</a></div>  <div id="navbar-collapse-02" class="collapse navbar-collapse">  <ul class="nav navbar-nav">               <li class="active propClone"><a href="#">Home</a></li>    <li class="propClone"><a href="#">Work</a></li>    <li class="propClone"><a href="#">Blog</a></li>    <li class="propClone"><a href="#">Contact</a></li>  </ul>  <ul class="nav navbar-nav navbar-right">    <li class="propClone">      <a href="#">Login <span class="fa fa-lock"></span></a>    </li>  </ul></div><!-- /.navbar-collapse --></nav><div class="row banner"><div class="col-md-12">  <h1 class="text-center editContent">    We have created the product that will help    <br>    your startup to look even better  </h1>  <div class="text-center margin-bottom-100">    <a href="#" class="btn btn-info btn-hg btn-embossed"><span class="fa fa-info-circle"></span> Learn more</a>    <a href="#" class="btn btn-primary btn-hg btn-embossed"><span class="fa fa-shopping-cart"></span> Buy now for $99</a>  </div></div></div><!-- /.row --></div><!-- /.container --></div><!-- /.wrapper --></header></div>'},
                                      { id: 'header2',
                                        type: 'header',
                                        thumbnail: '/website_builder/header2.png',
                                        height: 550,
                                        url: '/website_builder/header2.html',
                                        body_html: '<div id="page" class="page"><div class="item header padding-bottom-0" id="header2"><div class="wrapper"><div class="container"><nav role="navigation" class="navbar plain margin-top-20"><div class="navbar-header">  <button data-target="#navbar-collapse-02" data-toggle="collapse" class="navbar-toggle" type="button">    <span class="sr-only">Toggle navigation</span>  </button>  <a href="#" class="navbar-brand"><img alt="" src="website_builder/images/icons/brush.svg" style="height: 45px;"> HTML Builder</a>  </div>      <div id="navbar-collapse-02" class="collapse navbar-collapse">  <ul class="nav navbar-nav navbar-right">                <li class="active propClone"><a href="#">Home</a></li>    <li class="propClone"><a href="#">Work</a></li>    <li class="propClone"><a href="#">Blog</a></li>    <li class="propClone"><a href="#">Contact</a></li>  </ul>           </div><!-- /.navbar-collapse --></nav></div><!-- /.container --></div><!-- /.wrpaper --><header class="wrapper grey"><div class="container"> <div class="row banner2"><div class="col-md-7">  <h1 class="editContent">Vestibulum pellentesque nunc ac porta</h1>  <p class="editContent">    Proin ullamcorper non neque nec lacinia. Praesent sodales libero accumsan pulvinar tempus. Proin nec lacus enim. Vivamus ullamcorper iaculis arcu et semper. Nulla venenatis nibh sed ligula placerat bibendum. Suspendisse malesuada enim eget elit congue rutrum.  </p>  <a href="#" class="btn btn-primary btn-embossed btn-wide"><span class="fa fa-arrow-circle-o-right"></span> Learn more</a></div></div><!-- /.row --></div><!-- /.container --></div><!-- /.wrapper --></header><!-- /.item --></div></div>'},
                                        {  id: 'content_section1',
                                           type: 'content_section',
                                           thumbnail: '/website_builder/content_section1.png',
                                           height: 550,
                                           url: '/website_builder/content_section1.html',
                                           body_html: '<div id="page" class="page"><div class="item content" id="content_section1"><div class="container">  <div class="row"><div class="col-md-8"><div class="editContent"><h3>Aenean varius lorem at dui condimentum convallis</h3><p>  Ut non lobortis est. Ut dictum scelerisque luctus. Aliquam condimentum interdum odio, et fermentum nulla pharetra in. Praesent pellentesque neque nec eros tempus, ac venenatis ante interdum. Vivamus viverra est dolor, non placerat nunc commodo sed</p></div><br><div class="row">    <div class="col-md-6">        <div class="videoWrapper">      <iframe width="560" height="315" src="//www.youtube.com/embed/scy6aUCn_hs?controls=0&amp;showinfo=0" frameborder="0" allowfullscreen></iframe>      <div class="frameCover" data-type="video"></div>    </div>    </div>    <div class="col-md-6 editContent">      <h5>A Little Video</h5>        <p>      Can go a long way to make your content come alive! Hear hear! <a href="">Learn more</a>    </p>    </div></div></div><!-- ./col-md-8 --><div class="col-md-4"><br><blockquote class="editContent">  <p>Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. </p>  <small>Steve Jobs, CEO Apple</small></blockquote><br><a href="#" class="btn btn-primary btn-embossed btn-block margin-bottom-20"><span class="fa fa-linkedin-square"></span> Do Something Now!</a><a href="#" class="btn btn-default btn-embossed btn-block"><span class="fa fa-google-plus-square"></span> Do Something Else Next!</a></div><!-- /.col-md-4 --></div><!-- /.row --></div><!-- /.container --></div></div>'},
                                        { id: 'content_section4',
                                          type: 'content_section',
                                          thumbnail: '/website_builder/content_section4.png',
                                          height: 350,
                                          url: '/website_builder/content_section4.html',
                                          body_html: '<div id="page" class="page"><div class="item content" id="content_section1"><div class="container">    <div class="row"><div class="col-md-4">       <div class="col editContent">                  <h3>Column One</h3>        <p>      Ut non lobortis est. Ut dictum scelerisque luctus. Aliquam condimentum interdum odio, et fermentum nulla pharetra in.    </p>    </div><!-- /.col -->                              </div><!-- /.col-md-4 col --><div class="col-md-4 editContent">        <div class="col">                            <h3>Column Two</h3>        <p>      Ut non lobortis est. Ut dictum scelerisque luctus. Aliquam condimentum interdum odio, et fermentum nulla pharetra in.    </p>      </div><!-- /.col -->                              </div><!-- /.col-md-4 col --><div class="col-md-4 editContent">        <div class="col">                            <h3>Column Three</h3>        <p>      Ut non lobortis est. Ut dictum scelerisque luctus. Aliquam condimentum interdum odio, et fermentum nulla pharetra in.    </p>      </div><!-- /.col -->                              </div><!-- /.col-md-4 col --></div><!-- /.row --></div><!-- /.container --></div></div>'},
                                      {  id: 'footer1',
                                         type: 'footer',
                                         thumbnail: '/website_builder/footer1.png',
                                         height: 300,
                                         url: '/website_builder/footer1.html',
                                         body_html: ' <div id="page" class="page"> <div class="footerWrapper" id="footer1"><div class="item footer bottom-menu bottom-menu-large bottom-menu-inverse"><div class="container"><div class="row"><div class="col-md-2 navbar-brand">  <a class="" href="#fakelink"><img alt="" src="website_builder/images/icons/brush.svg"></a></div><div class="col-md-2">  <h5 class="title">ABOUT US</h5>  <ul class="bottom-links">    <li><a href="#fakelink">Dashboard</a></li>            <li><a href="#fakelink">Feed</a></li>            <li><a href="#fakelink">Forums</a></li>            <li><a href="#fakelink">Radio</a></li>            <li><a href="#fakelink">Journal</a></li>            <li><a href="#fakelink">Reader</a></li>            <li><a href="#fakelink">Store</a></li>  </ul></div><div class="col-md-2">  <h5 class="title">CATEGORIES</h5>  <ul class="bottom-links">            <li><a href="#fakelink">Design</a></li>            <li><a href="#fakelink">Freebies</a></li>            <li><a href="#fakelink">Tutorials</a></li>            <li><a href="#fakelink">Coding</a></li>            <li><a href="#fakelink">Inspiration</a></li>            <li><a href="#fakelink">WordPress</a></li>            <li><a href="#fakelink">Resources</a></li>  </ul></div><div class="col-md-2">  <h5 class="title">NETWORKS</h5>  <ul class="bottom-links">            <li><a href="#fakelink">Insight</a></li>            <li><a href="#fakelink">Promotion</a></li>            <li><a href="#fakelink">Production</a></li>            <li><a href="#fakelink">Planning</a></li>            <li><a href="#fakelink">Journal</a></li>            <li><a href="#fakelink">Reader</a></li>            <li><a href="#fakelink">Store</a></li>  </ul></div><div class="col-md-2">  <h5 class="title">MAINFRAME</h5>  <ul class="bottom-links">            <li><a href="#fakelink">Register / Login</a></li>            <li class="active"><a href="#fakelink">Jobs</a></li>            <li><a href="#fakelink">Contacts</a></li>            <li><a href="#fakelink">Privacy</a></li>            <li><a href="#fakelink">Terms of Use</a></li>  </ul></div><div class="col-md-2">  <h5 class="title">FOLLOW US</h5>  <ul class="bottom-links">            <li><a href="#fakelink">Facebook</a></li>            <li><a href="#fakelink">Twitter</a></li>            <li><a href="#fakelink">Youtube</a></li>            <li><a href="#fakelink">Vimeo</a></li>            <li><a href="#fakelink">Instagram</a></li>            <li><a href="#fakelink">Vine&nbsp;&nbsp;<span class="label label-small label-primary">New</span></a></li>  </ul></div></div></div>  </div><!-- /.item --></div><!-- /.footerWrapper --></div>'},
                                       { id: 'footer2',
                                         type: 'footer',
                                         thumbnail: '/website_builder/footer2.png',
                                         height: 200,
                                         url: '/website_builder/footer2.html',
                                         body_html: '<div id="page" class="page"><div class="footerWrapper" id="footer2"><div class="item footer bottom-menu"><div class="container">   <div class="row"> <div class="col-md-2">   <a class="bottom-menu-brand" href="#fakelink"><img src="website_builder/images/icons/brush.svg" class="small" style="height: 30px"></a></div>   <div class="col-md-8"><ul class="bottom-menu-list">   <li><a href="#fakelink">About Us</a></li>  <li><a href="#fakelink">Store</a></li>  <li class="active"><a href="#fakelink">Jobs</a></li>  <li><a href="#fakelink">Privacy</a></li>  <li><a href="#fakelink">Terms</a></li>  <li><a href="#fakelink">Follow Us</a></li>  <li><a href="#fakelink">Support</a></li>  <li><a href="#fakelink">Links</a></li></ul></div><div class="col-md-2"><ul class="bottom-menu-iconic-list">  <li><a class="fa fa-pinterest" href="#fakelink"></a></li>  <li><a class="fa fa-facebook" href="#fakelink"></a></li>  <li><a class="fa fa-twitter" href="#fakelink"></a></li></ul></div>   </div>   </div></div><!-- /.item --></div><!-- /.footerWrapper --></div>' } ]

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
