local ver = "0.01"


if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end


if GetObjectName(GetMyHero()) ~= "Kayle" then return end

require("OpenPredict")
require("DamageLib")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat('<font color = "#00FFFF">New version found! ' .. data)
        PrintChat('<font color = "#00FFFF">Downloading update, please wait...')
        DownloadFileAsync('https://raw.githubusercontent.com/allwillburn/Kayle/master/Kayle.lua', SCRIPT_PATH .. 'Kayle.lua', function() PrintChat('<font color = "#00FFFF">Update Complete, please 2x F6!') return end)
    else
        PrintChat('<font color = "#00FFFF">No updates found!')
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/allwillburn/Kayle/master/Kayle.version", AutoUpdate)


GetLevelPoints = function(unit) return GetLevel(unit) - (GetCastLevel(unit,0)+GetCastLevel(unit,1)+GetCastLevel(unit,2)+GetCastLevel(unit,3)) end
local SetDCP, SkinChanger = 0

local KayleQ = {delay = .5, range = 650, width = 250, speed = 1200}

local KayleMenu = Menu("Kayle", "Kayle")

KayleMenu:SubMenu("Combo", "Combo")

KayleMenu.Combo:Boolean("Q", "Use Q in combo", true)
KayleMenu.Combo:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
KayleMenu.Combo:Boolean("W", "Use W in combo", true)
KayleMenu.Combo:Boolean("E", "Use E in combo", true)
KayleMenu.Combo:Boolean("R", "Use R in combo", false)
KayleMenu.Combo:Slider("RX", "X Enemies to Cast R",3,1,5,1)
KayleMenu.Combo:Boolean("Cutlass", "Use Cutlass", true)
KayleMenu.Combo:Boolean("Tiamat", "Use Tiamat", true)
KayleMenu.Combo:Boolean("BOTRK", "Use BOTRK", true)
KayleMenu.Combo:Boolean("RHydra", "Use RHydra", true)
KayleMenu.Combo:Boolean("YGB", "Use GhostBlade", true)
KayleMenu.Combo:Boolean("Gunblade", "Use Gunblade", true)
KayleMenu.Combo:Boolean("Randuins", "Use Randuins", true)
KayleMenu.Combo:Boolean("Protobelt", "Use Protobelt", true)


KayleMenu:SubMenu("AutoMode", "AutoMode")
KayleMenu.AutoMode:Boolean("Level", "Auto level spells", false)
KayleMenu.AutoMode:Boolean("Ghost", "Auto Ghost", false)
KayleMenu.AutoMode:Boolean("Q", "Auto Q", false)
KayleMenu.AutoMode:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
KayleMenu.AutoMode:Boolean("W", "Auto W", false)
KayleMenu.AutoMode:Boolean("E", "Auto E", false)
KayleMenu.AutoMode:Boolean("R", "Auto R", false)

KayleMenu:SubMenu("LaneClear", "LaneClear")
KayleMenu.LaneClear:Boolean("Q", "Use Q", true)
KayleMenu.LaneClear:Boolean("W", "Use W", true)
KayleMenu.LaneClear:Boolean("E", "Use E", true)
KayleMenu.LaneClear:Boolean("RHydra", "Use RHydra", true)
KayleMenu.LaneClear:Boolean("Tiamat", "Use Tiamat", true)

KayleMenu:SubMenu("Harass", "Harass")
KayleMenu.Harass:Boolean("Q", "Use Q", true)
KayleMenu.Harass:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
KayleMenu.Harass:Boolean("W", "Use W", true)

KayleMenu:SubMenu("KillSteal", "KillSteal")
KayleMenu.KillSteal:Boolean("Q", "KS w Q", true)
KayleMenu.KillSteal:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
KayleMenu.KillSteal:Boolean("E", "KS w E", true)

KayleMenu:SubMenu("AutoIgnite", "AutoIgnite")
KayleMenu.AutoIgnite:Boolean("Ignite", "Ignite if killable", true)

KayleMenu:SubMenu("Drawings", "Drawings")
KayleMenu.Drawings:Boolean("DQ", "Draw Q Range", true)


KayleMenu:SubMenu("SkinChanger", "SkinChanger")
KayleMenu.SkinChanger:Boolean("Skin", "UseSkinChanger", true)
KayleMenu.SkinChanger:Slider("SelectedSkin", "Select A Skin:", 1, 0, 6, 1, function(SetDCP) HeroSkinChanger(myHero, SetDCP)  end, true)

KayleMenu:SubMenu("", "")

KayleMenu:SubMenu("", "")

KayleMenu:SubMenu("Warning Using R in Combo May Get You Banned ", "Warning Using R in Combo May Get You Banned ")

OnTick(function (myHero)
	local target = GetCurrentTarget()
        local YGB = GetItemSlot(myHero, 3142)
	local RHydra = GetItemSlot(myHero, 3074)
	local Tiamat = GetItemSlot(myHero, 3077)
        local Gunblade = GetItemSlot(myHero, 3146)
        local BOTRK = GetItemSlot(myHero, 3153)
        local Cutlass = GetItemSlot(myHero, 3144)
        local Randuins = GetItemSlot(myHero, 3143)
	local Protobelt = GetItemSlot(myHero, 3152)	
        local ally = ClosestAlly

	--AUTO LEVEL UP
	if KayleMenu.AutoMode.Level:Value() then

			spellorder = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
			if GetLevelPoints(myHero) > 0 then
				LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			end
	end
        
        --Harass
          if Mix:Mode() == "Harass" then
            if KayleMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 650) then
                local QPred = GetPrediction(target,KayleQ)
                       if QPred.hitChance > (KayleMenu.Harass.Qpred:Value() * 0.1) then
                                 CastSkillShot(_Q,QPred.castPos)
                       end
            end
            if KayleMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 1000) then
				CastSpell(_W)
            end     
          end

	--COMBO
		
	  
	  if Mix:Mode() == "Combo" then
            if KayleMenu.Combo.YGB:Value() and YGB > 0 and Ready(YGB) and ValidTarget(target, 700) then
			CastSpell(YGB)
            end

            if KayleMenu.Combo.Randuins:Value() and Randuins > 0 and Ready(Randuins) and ValidTarget(target, 500) then
			CastSpell(Randuins)
            end

            if KayleMenu.Combo.BOTRK:Value() and BOTRK > 0 and Ready(BOTRK) and ValidTarget(target, 550) then
			 CastTargetSpell(target, BOTRK)
            end

            if KayleMenu.Combo.Cutlass:Value() and Cutlass > 0 and Ready(Cutlass) and ValidTarget(target, 700) then
			 CastTargetSpell(target, Cutlass)
            end

            if KayleMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 500) then
			 CastSkillShot(_E, target)
	    end

           
            if KayleMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 650) then
                local QPred = GetPrediction(target,KayleQ)
                       if QPred.hitChance > (KayleMenu.Combo.Qpred:Value() * 0.1) then
                                 CastSkillShot(_Q,QPred.castPos)
                       end
            end
            if KayleMenu.Combo.Tiamat:Value() and Tiamat > 0 and Ready(Tiamat) and ValidTarget(target, 350) then
			CastSpell(Tiamat)
            end
			
	    		

            if KayleMenu.Combo.Gunblade:Value() and Gunblade > 0 and Ready(Gunblade) and ValidTarget(target, 700) then
			CastTargetSpell(target, Gunblade)
            end
			
	    if KayleMenu.Combo.Protobelt:Value() and Protobelt > 0 and Ready(Protobelt) and ValidTarget(target, 700) then
			CastSkillShot(Protobelt, target)
            end		

            if KayleMenu.Combo.RHydra:Value() and RHydra > 0 and Ready(RHydra) and ValidTarget(target, 400) then
			CastSpell(RHydra)
            end
            
	    if KayleMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 500) then
			CastSpell(_W)
	    end
	    
	    local ally = ClosestAlly

            if KayleMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 300) and (EnemiesAround(myHeroPos(), 300) >= KayleMenu.Combo.RX:Value()) then
			CastSpell(_R)
            end

            if KayleMenu.Combo.R:Value() and Ready(_R) and GetCurrentHP(myhero) < 250 and (EnemiesAround(myHeroPos(), 900) >= KayleMenu.Combo.RX:Value()) then
			CastSpell(_R)
            end

          end

         --AUTO IGNITE
	for _, enemy in pairs(GetEnemyHeroes()) do
		
		if GetCastName(myHero, SUMMONER_1) == 'SummonerDot' then
			 Ignite = SUMMONER_1
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end

		elseif GetCastName(myHero, SUMMONER_2) == 'SummonerDot' then
			 Ignite = SUMMONER_2
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end
		end

	end

        for _, enemy in pairs(GetEnemyHeroes()) do
                
                if IsReady(_Q) and ValidTarget(enemy, 650) and KayleMenu.KillSteal.Q:Value() and GetHP(enemy) < getdmg("Q",enemy) then
		         local QPred = GetPrediction(target,KayleQ)
                       if QPred.hitChance > (KayleMenu.KillSteal.Qpred:Value() * 0.1) then
                                 CastSkillShot(_Q,QPred.castPos)
                       end
            end

                if IsReady(_E) and ValidTarget(enemy, 500) and KayleMenu.KillSteal.E:Value() and GetHP(enemy) < getdmg("E",enemy) then
		                      CastSkillShot(_E, target)
  
                end
      end

      if Mix:Mode() == "LaneClear" then
      	  for _,closeminion in pairs(minionManager.objects) do
	        if KayleMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 650) then
	        	CastSkillShot(_Q, closeminion)
                end

                

                if KayleMenu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 500) then
	        	CastSpell(_E)
	        end

                if KayleMenu.LaneClear.Tiamat:Value() and ValidTarget(closeminion, 350) then
			CastSpell(Tiamat)
		end
	
		if KayleMenu.LaneClear.RHydra:Value() and ValidTarget(closeminion, 400) then
                        CastTargetSpell(closeminion, RHydra)
      	        end
          end
      end
        --AutoMode
        if KayleMenu.AutoMode.Q:Value() then        
          if Ready(_Q) and ValidTarget(target, 650) then
		      local QPred = GetPrediction(target,KayleQ)
                       if QPred.hitChance > (KayleMenu.AutoMode.Qpred:Value() * 0.1) then
                                 CastSkillShot(_Q,QPred.castPos)
                       end
                 end
            end
        if KayleMenu.AutoMode.W:Value() then        
          if Ready(_W) and ValidTarget(target, 1000) then
	  	      CastSpell(_W)
          end
        end
        if KayleMenu.AutoMode.E:Value() then        
	  if Ready(_E) and ValidTarget(target, 1000) then
		      CastSpell(_E)
	  end
        end
        if KayleMenu.AutoMode.R:Value() and GetCurrentHP(myhero) < 250 then        
	  if Ready(_R) then
		      CastSpell(_R)
	  end
        end
                
	--AUTO GHOST
	if KayleMenu.AutoMode.Ghost:Value() then
		if GetCastName(myHero, SUMMONER_1) == "SummonerHaste" and Ready(SUMMONER_1) then
			CastSpell(SUMMONER_1)
		elseif GetCastName(myHero, SUMMONER_2) == "SummonerHaste" and Ready(SUMMONER_2) then
			CastSpell(Summoner_2)
		end
	end
end)

OnDraw(function (myHero)
        
         if KayleMenu.Drawings.DQ:Value() then
		DrawCircle(GetOrigin(myHero), 650, 0, 200, GoS.Black)
	end
		
	

end)


OnProcessSpell(function(unit, spell)
	local target = GetCurrentTarget()        
       
               

        if unit.isMe and spell.name:lower():find("itemtiamatcleave") then
		Mix:ResetAA()
	end	
               
        if unit.isMe and spell.name:lower():find("itemravenoushydracrescent") then
		Mix:ResetAA()
	end

end) 


local function SkinChanger()
	if KayleMenu.SkinChanger.UseSkinChanger:Value() then
		if SetDCP >= 0  and SetDCP ~= GlobalSkin then
			HeroSkinChanger(myHero, SetDCP)
			GlobalSkin = SetDCP
		end
        end
end


print('<font color = "#01DF01"><b>Kayle</b> <font color = "#01DF01">by <font color = "#01DF01"><b>Allwillburn</b> <font color = "#01DF01">Loaded!')





