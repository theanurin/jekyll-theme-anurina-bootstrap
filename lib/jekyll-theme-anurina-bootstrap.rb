require "jekyll"

class MisconfigurationError < RuntimeError
end

#
# Hook: Just after the site initializes. Good for modifying the configuration of the site. Triggered once per build / serve session
# https://jekyllrb.com/docs/plugins/hooks/
#
Jekyll::Hooks.register :site, :after_init do |site|
  if site.config["permalink"] == "none"
    Jekyll.logger.info "Anurina:", "Check config 'permalink' is 'none'"
  elsif site.config["permalink"] == "" || site.config["permalink"] == "date"
    site.config["permalink"] = "none"
    Jekyll.logger.info "Anurina:", "Set config 'permalink' to 'none'"
  else
    raise MisconfigurationError.new(
      "Pls remove 'permalink' from your config.yml or set explicitly to 'none'. Current value is '#{site.config["permalink"]}'."
    )
  end

  if site.config["collections_dir"] == "content"
    Jekyll.logger.info "Anurina:", "Check config 'collections_dir' is 'content'"
  elsif site.config["collections_dir"] != ""
    raise MisconfigurationError.new("Pls remove 'collections_dir' from your config.yml or set explicitly to 'content'")
  else
    site.config["collections_dir"] = "content"
    Jekyll.logger.info "Anurina:", "Set config 'collections_dir' to 'content'"
  end

  site.config["collections"].each do |name, config|
    if name == "drafts"
      Jekyll.logger.info "Anurina:", "Checking collection '#{name}' output to be 'false'"
      if config["output"] != false
        raise MisconfigurationError.new("A collection '#{name}' is not supported by the theme. Pls remove it from your config.yml at all or set 'output' explicitly to 'false'. Collections are reserved for multi-language usage (it will be generated automatically).")
      end
    elsif name == "posts"
      # Skip posts due to unable to disable it via config.yaml
      # see https://talk.jekyllrb.com/t/i-dont-want-posts-on-my-website-how-to-remove-this-default-collection/1605
    else
      raise MisconfigurationError.new("Pls remove 'collections' from your config.yml. Collections are reserved for multi-language usage (it will be generated automatically).")
    end
  end

  # Remove all collection provided by config.yaml
  site.config["collections"].each do |name, config|
    site.config["collections"].delete(name)
  end

  raise MisconfigurationError.new(
    "Pls provider locale sequence in your _config.yaml. A value for anurina->locale->sequence is not presented."
  ) unless site.config["anurina"] && site.config["anurina"]["locale"] && site.config["anurina"]["locale"]["sequence"]
  locales = site.config["anurina"]["locale"]["sequence"]
  locales.each_with_index do |locale, index|
    #
    # See https://stackoverflow.com/questions/8758340/is-there-a-regex-to-test-if-a-string-is-for-a-locale
    #
    raise MisconfigurationError.new(
      "Bad locale name '#{locale}'. The name is not match to /^[a-zA-Z]{2,4}(([\-\_][a-zA-Z]{4})+)?([\-\_][a-zA-Z]{2})?$/"
    ) unless locale.match(/^[a-zA-Z]{2,4}(([\-\_][a-zA-Z]{4})+)?([\-\_][a-zA-Z]{2})?$/)

    #
    # Setup Front Matter Defaults. See https://jekyllrb.com/docs/configuration/front-matter-defaults/
    #
    site.config["defaults"].push({
      "scope" => {
        "path" => "", # an empty string here means all files in the project (or collection by type)
        "type" => locale,
      },
      "values" => {
        "layout" => "page",
        # "permalink" => "/:collection/:slug",
      }
    })
    site.config["defaults"].push({
      "scope" => {
        "path" => "_#{locale}/news",
        "type" => locale,
      },
      "values" => {
        "layout" => "post",
        # "permalink" => "/#{locale}/news/:slug",
      }
    })
    # Jekyll.logger.info "Anurina:", site.config["defaults"]

    # raise MisconfigurationError

    site.config["collections"][locale] = {
      "output" => true,
      "paginate" => true,
      "lang_sort_order": index
    }

    Jekyll.logger.info "Anurina:", "Register ##{index} locale collection '#{locale}'"
  end
end

#
# Hook: Whenever a page is initialized
# https://jekyllrb.com/docs/plugins/hooks/
#
Jekyll::Hooks.register :pages, :post_init do |page, payload|
  if page.dir == "/content/"
    raise MisconfigurationError.new("Pls move page '#{page.relative_path}' outside of 'content/' directory. The directory 'content/' are reserved for collections usage ONLY.")
  end
end

#
# Hook: Whenever a post is initialized
# https://jekyllrb.com/docs/plugins/hooks/
#
Jekyll::Hooks.register :documents, :post_init do |document, payload|
  collection_name = document.collection.label
  if collection_name == "posts" || collection_name == "drafts"
    Jekyll.logger.info "Anurina:",  "Processing document #{document.relative_path}"
    raise MisconfigurationError.new("Pls remove unsupported 'content/_posts' and 'content/_drafts' from your project to use the theme.")
  end
end