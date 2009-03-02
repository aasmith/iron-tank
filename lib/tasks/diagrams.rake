namespace :doc do
  namespace :diagram do
    desc "Generates SVG of models."
    task :models do
      sh "railroad -i -l -a -m -M | dot -Tsvg | sed 's/font-size:14.00/font-size:11.00/g' > doc/models.svg"
    end

    desc "Generates SVG of controllers."
    task :controllers do
      sh "railroad -i -l -C | neato -Tsvg | sed 's/font-size:14.00/font-size:11.00/g' > doc/controllers.svg"
    end
  end

  desc "Generates SVG of application."
  task :diagrams => %w(diagram:models diagram:controllers)
end

