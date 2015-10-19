require 'activeadmin-sortable/version'
require 'activeadmin'
require 'rails/engine'

module ActiveAdmin
  module Sortable
    module ControllerActions
      def sortable
        config.sort_order = :position_asc
        config.paginate = false

        member_action :sort, :method => :post do
          params[:position].to_i > 0 ? resource.insert_at(params[:position].to_i + ((resource.position > params[:position].to_i)?1:0)) : resource.move_to_top
          head 200
        end

        member_action :up do
          resource.move_higher
          redirect_to collection_path
        end

        member_action :down do
          resource.move_lower
          redirect_to collection_path
        end

        member_action :to_top do
          resource.move_to_top
          redirect_to collection_path
        end

        member_action :to_bottom do
          resource.move_to_bottom
          redirect_to collection_path
        end
      end
    end

    module TableMethods
      HANDLE = '&#x2195;'.html_safe

      def sortable_handle_column
        column '', :class => "activeadmin-sortable" do |resource|
          sort_url = "#{resource_path(resource)}/sort"
          content_tag :span, HANDLE, class: 'handle', data: { url: sort_url, position: resource.position }
        end
      end

      def sortable_actions(options = {})
        options = { name: I18n.t('active_admin.sortable.column') }.merge(options)

        column options[:name] do |resource|
          links = ''.html_safe
          links << link_to(I18n.t('active_admin.sortable.to_top'), "#{resource_path(resource)}/to_top?#{params.except(:controller, :action, :order).to_query}", class: 'member_link')
          links << link_to(I18n.t('active_admin.sortable.up'), "#{resource_path(resource)}/up?#{params.except(:controller, :action, :order).to_query}", class: 'member_link')
          links << link_to(I18n.t('active_admin.sortable.down'), "#{resource_path(resource)}/down?#{params.except(:controller, :action, :order).to_query}", class: 'member_link')
          links << link_to(I18n.t('active_admin.sortable.to_bottom'), "#{resource_path(resource)}/to_bottom?#{params.except(:controller, :action, :order).to_query}", class: 'member_link')
          links
        end
      end
    end

    ::ActiveAdmin::ResourceDSL.send(:include, ControllerActions)
    ::ActiveAdmin::Views::TableFor.send(:include, TableMethods)

    class Railtie < ::Rails::Railtie
      config.to_prepare do
        require 'active_support/i18n'
        I18n.load_path += Dir[File.expand_path('../activeadmin-sortable/locales/*.yml', __FILE__)]
      end
    end

    class Engine < ::Rails::Engine
      # Including an Engine tells Rails that this gem contains assets
    end
  end
end


