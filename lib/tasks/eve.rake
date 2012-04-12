namespace :eve do
  namespace :report do
    desc "Reports and stuff."

    task :margin => :environment do
      report = []
      
      BlueprintInventory.find(:all, :conditions => "material_efficiency > 0").each do |bp|
         report << {
           :name => bp.blueprint.product_name,
           :profit_est => (bp.blueprint.last_sell_price - bp.blueprint.unit_cost(bp.material_efficiency))
         } unless bp.blueprint.last_sell_price == 0.0 
      end # BP loop
      
      report.sort { |a,b| b[:profit_est] <=> a[:profit_est] }.each do |line|
        print "#{line[:profit_est]}\t\t#{line[:name]}\n"
      end # print loop
    end # task margin
  end # namespace report

  namespace :db do
  
    desc "Pulls static data (BPs, materials, etc) from the EVE database dump."
    task :import => :environment do
      # This task requires the eve_dump database be loaded with the EVE database extract.
      # The MySQL version of this extract was provided by ``Jercy Fravowitz''. It was
      # located at <http://eve.no-ip.de/apo15/>. CCP releases the extract in a format only
      # MS SQL can understand.

      # Truncate the static data tables...
      %w[item_groups blueprints blueprint_materials blueprint_skills trade_hubs item_types packaged_ship_volumes].each {|table|
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table}")
      }

      ["INSERT INTO item_groups 
        (id,group_name)
        SELECT 
          invGroups.groupID AS id, 
          invGroups.groupName AS group_name
        FROM eve_dump.invGroups 
        WHERE invGroups.published = 1 
        AND invGroups.categoryID IN (4,9)",
        
        "INSERT INTO blueprints 
        (id,blueprint_name,item_group_id,product_item_id,product_name,product_batch_quantity,base_price,tech_level,production_limit,waste_factor)
        SELECT
          invTypes.typeID AS id,
          invTypes.typeName AS blueprint_name,
          invTypes.groupID AS group_id,
          invTypeProduct.typeID AS product_item_id,
          invTypeProduct.typeName AS product_name,
          invTypeProduct.portionSize AS product_quantity,
          invTypes.basePrice AS blueprint_base_price,
          invBlueprintTypes.techLevel AS product_tech_level,
          invBlueprintTypes.maxProductionLimit AS production_limit,
          invBlueprintTypes.wasteFactor AS waste_factor
        FROM eve_dump.invTypes
        INNER JOIN eve_dump.invBlueprintTypes ON invTypes.typeID = invBlueprintTypes.blueprintTypeID
        INNER JOIN eve_dump.invTypes AS invTypeProduct ON invBlueprintTypes.productTypeId = invTypeProduct.typeID
        WHERE invTypes.published = 1",

        "INSERT INTO blueprint_materials
        (material_type_id,blueprint_id,material_name,quantity,damage_per_job,material_type,item_group_id)
        SELECT 
          invTypes.typeID AS material_type_id,
          typeActivityMaterials.typeID AS blueprint_type_id,
          invTypes.typeName AS material_name,
          typeActivityMaterials.quantity AS quantity,         
          typeActivityMaterials.damagePerJob AS damage_per_job,
          'raw' AS meterial_type,
          invTypes.groupID
        FROM eve_dump.typeActivityMaterials
        INNER JOIN eve_dump.invTypes ON typeActivityMaterials.requiredtypeID = invTypes.typeID
        INNER JOIN eve_dump.invGroups ON invTypes.groupID = invGroups.groupID
        INNER JOIN eve_dump.invBlueprintTypes ON typeActivityMaterials.typeID = invBlueprintTypes.blueprintTypeID
        WHERE typeActivityMaterials.activityId = 1 -- Manufacturing
        AND invGroups.categoryID NOT IN (7,16) -- Modules, skills
        AND typeActivityMaterials.quantity > 0
        AND invTypes.published = 1",

        "INSERT INTO blueprint_materials
        (material_type_id,blueprint_id,material_name,quantity,damage_per_job,material_type,item_group_id)
        SELECT
          invTypes.typeID AS material_type_id,
          typeActivityMaterials.typeID AS blueprint_type_id,
          invTypes.typeName AS material_name, 
          typeActivityMaterials.quantity AS quantity, 
          typeActivityMaterials.damagePerJob AS damage_per_job,
          'component' AS material_type,
          invTypes.groupID
        FROM eve_dump.typeActivityMaterials
        INNER JOIN eve_dump.invTypes ON typeActivityMaterials.requiredtypeID = invTypes.typeID
        INNER JOIN eve_dump.invGroups ON invTypes.groupID = invGroups.groupID
        WHERE typeActivityMaterials.activityId = 1 -- Manufacturing
        AND invGroups.categoryID IN (6,7) -- Ships, modules
        AND invTypes.published = 1",

        "INSERT INTO blueprint_skills
        (skill_type_id,blueprint_id,skill_name,level)
        SELECT
          invTypes.typeID AS skill_type_id,
          typeActivityMaterials.typeID AS blueprint_type_id,  
          invTypes.typeName AS skill_name, 
          typeActivityMaterials.quantity AS level
        FROM eve_dump.typeActivityMaterials
        INNER JOIN eve_dump.invTypes ON typeActivityMaterials.requiredtypeID = invTypes.typeID
        INNER JOIN eve_dump.invGroups ON invTypes.groupID = invGroups.groupID
        WHERE typeActivityMaterials.activityId = 1 
        AND invGroups.categoryID = 16
        AND invTypes.published = 1",
      
        # This stamps the correct meta-level (if available) of the product on to
        # the BP. The metalevel will be handy for grabbing all T1 material costs...
        # Don't care about ferrogel or base T1 items right now! Too much data.
        "UPDATE blueprints, eve_dump.dgmTypeAttributes 
        SET 
          blueprints.meta_level = IFNULL(valueInt,valueFloat) 
        WHERE blueprints.product_item_id = dgmTypeAttributes.typeID 
        AND dgmTypeAttributes.attributeID = 633",

        "INSERT INTO trade_hubs 
        (id,station_name) 
        SELECT 
          stationID, 
          stationName
        FROM eve_dump.staStations 
        WHERE stationID IN (60003760,60008494,60004588,60005686,60011740)",

        "UPDATE item_groups SET poll_price = 1 WHERE id IN (18,754)",

        # This is some bullshit to fix CCP's fuckup. Packaged ship/can volumes are
        # grabbed from a static, hard-coded hash in the code - not the database.
        # NJ, guys. Let's not store the fucking data in the fucking database.
        "INSERT INTO packaged_ship_volumes
        (item_group_id,volume_m3) VALUES
        (448,1000),(12,1000),(274,1000),(340,1000),(324,2500),(419,15000),(27,50000),(898,50000),(883,1000000),(547,1000000),(906,10000),(540,15000),(830,2500),(26,10000),(420,5000),(485,1000000),(893,2500),(543,3750),(833,10000),(513,1000000),(25,2500),(358,10000),(894,10000),(28,20000),(941,500000),(831,2500),(541,5000),(902,1000000),(832,10000),(900,50000),(463,3750),(659,1000000),(237,2500),(31,500),(834,2500),(963,5000),(30,10000000),(380,20000)",

        "INSERT INTO item_types (id,name,item_group_id,volume_m3)
        SELECT 
          typeID, 
          typeName, 
          groupID,
          volume 
        FROM eve_dump.invTypes",

        "UPDATE item_types, packaged_ship_volumes 
        SET 
          item_types.volume_m3 = packaged_ship_volumes.volume_m3 
        WHERE item_types.item_group_id = packaged_ship_volumes.item_group_id",
      ].each {|query|
        ActiveRecord::Base.connection.execute(query)
      }
    end # import
  end # db namespace

  namespace :poll do
    
    desc "Gets pricing data from EVE Central for materials."
    task :material_prices  => :environment do
      client = PriceUpdater::MarketStat.new() # No options for now...defaults are fine.
      client.update
    end # material_prices

    desc "Downloads the daily market log CSV and imports orders from the major tradehubs."
    task :tradehub_prices => :environment do
      client = PriceUpdater::MarketLog.new()
      client.download
      client.update
    end # tradehub_prices

    desc "Pulls corp market orders via the EVE API."
    task :market_orders => :environment do
      #client = APIImporter::MarketLog.new(96327,'rMjjVY5fMFoiTQGgCUZ0SH6CnHUX8pb6baiRLZsImQ7tq6tmX9BqGsm5bOVSyzlI',144845181)
      char = Character.find(:first, :conditions => {:active => true})
      client = APIImporter::MarketLog.new(char.api_user_id,char.api_full_key,char.api_character_id)
      client.update
    end # orders
  end # poll namespace
end # eve
