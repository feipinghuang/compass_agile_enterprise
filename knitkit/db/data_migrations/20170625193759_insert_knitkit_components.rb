class InsertKnitkitComponents

  def self.up
    components = [ { iid: 'header1',
                     title: 'Header',
                     type: 'header',
                     thumbnail: '/images/content_blocks/header1.png',
                     height: 581 },
                   { iid: 'header2',
                     title: 'Header',
                     type: 'header',
                     thumbnail: '/images/content_blocks/header2.png',
                     height: 581 },
                   {  iid: 'content_section1',
                      title: 'Content Section',
                      type: 'content_section',
                      thumbnail: '/images/content_blocks/one_column.png',
                      height: 550 },
                   {  iid: 'content_section2',
                      title: 'Content Section',
                      type: 'content_section',
                      thumbnail: '/images/content_blocks/three_column.png',
                      height: 550 },
                   { iid: 'footer1',
                     title: 'Footer',
                     type: 'footer',
                     thumbnail: '/images/content_blocks/footer1.png',
                     height: 114 },
                   {  iid: 'footer2',
                      title: 'Footer',
                      type: 'footer',
                      thumbnail: '/images/content_blocks/footer2.png',
                      height: 245
                      }
                   ]

    Component.destroy_all
    components.each do |component|
      unless Component.where(internal_identifier: "#{component[:iid]}").first
        Component.create!({
                            title: component[:title],
                            body_html: component[:body_html],
                            internal_identifier: "#{component[:iid]}",
                            custom_data: { thumbnail: component[:thumbnail],
                                           height: component[:height],
                                           component_type: component[:type].downcase }
        })
      end ## unless block
    end ## Component array loop
  end

  def self.down
    Component.destroy_all
  end

end
