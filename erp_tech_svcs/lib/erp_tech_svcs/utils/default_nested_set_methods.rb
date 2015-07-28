module ErpTechSvcs
  module Utils
    module DefaultNestedSetMethods
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # returns an array of hashes which represent all nodes in nested set order,
        # each of which consists of the node's id, internal identifier and representation
        # if a parent is passed it starts there in the tree
        def to_all_representation(parent=nil, container_arr=[], level=0)
          if parent
            parent.children.each do |node|
              container_arr << {id: node.id,
                                description: node.to_representation(level),
                                internal_identifier: node.internal_identifier}

              unless node.leaf?
                to_all_representation(node, container_arr, (level + 1))
              end

            end
          else
            self.roots.each do |root|
              root.children.each do |node|
                container_arr << {id: node.id,
                                  description: node.to_representation(level),
                                  internal_identifier: node.internal_identifier}

                unless node.leaf?
                  to_all_representation(node, container_arr, (level + 1))
                end

              end
            end
          end

          container_arr
        end

        def find_roots
          where("parent_id is null")
        end

        def find_children(parent_id = nil)
          parent_id.to_i == 0 ? self.roots : find(parent_id).children
        end

        # find_by_ancestor_iids
        # allows you to find a nested set element by the internal_identifiers in its ancestry
        # for example, to find a GlAccount whose internal_identifier is “site_4”, and whose parent’s internal_identifier is “nightly_room_charge”
        # and whose grandparent’s internal_identifier is “charge”, you would make this call:
        # gl_account = GlAccount.find_by_iids(['charge', 'nightly_room_charge', "site_4"])
        def find_by_ancestor_iids(iids)
          node = nil

          if iids.is_a? Array
            iids.each do |iid|
              if (iid == iids.first)
                node = where("parent_id is null and internal_identifier = ?", iid).first
              else
                node = where("parent_id = ? and internal_identifier = ?", node.id, iid).first
              end
            end
          end

          node
        end

        # find existing node or create it and return it.  Parent can be passed
        # which will scope this node by the parent
        def find_or_create(iid, description, parent=nil)
          # look for it
          record = if parent
                     parent.children.find_by_internal_identifier(iid)
                   else
                     find_by_internal_identifier(iid)
                   end

          unless record
            record = create(description: description, internal_identifier: iid)

            if parent
              record.move_to_child_of(parent)
            end
          end

          record
        end

      end

      def to_label
        description
      end

      def leaf
        children.size == 0
      end

      def to_json_with_leaf(options = {})
        self.to_json_without_leaf(options.merge(:methods => :leaf))
      end

      alias_method_chain :to_json, :leaf

      def to_tree_hash(options={})
        options = {
            only: [:parent_id, :internal_identifier],
            leaf: self.leaf?,
            text: self.to_label,
            children: self.children.collect { |child| child.to_tree_hash(options) }
        }.merge(options)

        self.to_hash(options)
      end

      def children_to_tree_hash(options={})
        self.children.collect { |child| child.to_tree_hash(options) }
      end

      def to_representation(level)
        # returns a string that consists of 1) a number of dashes equal to
        # the category's level and 2) the category's description attr
        rep = ''

        if level > 0
          level.times { rep << '-' }
          rep += ' '
        end

        rep << description
      end

      def to_record_representation(root = self.class.root)
        # returns a string of category descriptions like
        # 'main_category > sub_category n > ... > this category instance'
        if root?
          description
        else
          crawl_up_from(self, root).split('///').reverse.join(' > ')
        end
      end

      def is_descendant_of?(role_type)
        role_type = RoleType.iid(role_type) if (role_type.is_a? String)
        parent = self.parent

        if (role_type.id == self.id)
          result = true
        elsif parent.nil?
          result = false
        elsif parent.id == role_type.id
          result = true
        else
          result = parent.is_descendant_of? role_type
        end
        result
      end

      private

      def crawl_up_from(node, to_node = self.class.root)
        # returns a string that is a '///'-separated list of nodes
        # from child node to root
        "#{node.description}///#{crawl_up_from(node.parent, to_node) if node != to_node}"
      end


    end #DefaultNestedSetMethods
  end #Utils
end #ErpTechSvcs

