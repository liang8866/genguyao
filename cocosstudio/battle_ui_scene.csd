<GameProjectFile>
  <PropertyGroup Type="Scene" Name="battle_ui_scene" ID="5e1c1ff3-7943-4308-acfa-7313b0a160ae" Version="2.3.2.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Scene" Tag="81" ctype="GameNodeObjectData">
        <Size X="1024.0000" Y="576.0000" />
        <Children>
          <AbstractNodeData Name="Panel_mid" ActionTag="43726164" Tag="87" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" BackColorAlpha="102" ColorAngle="90.0000" ctype="PanelObjectData">
            <Size X="1024.0000" Y="576.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="512.0000" Y="288.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="Panel_top" ActionTag="-652824090" Tag="45" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" BackColorAlpha="102" ColorAngle="90.0000" ctype="PanelObjectData">
            <Size X="1024.0000" Y="576.0000" />
            <Children>
              <AbstractNodeData Name="player_bar" ActionTag="-2118146033" Tag="48" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="34.7800" RightMargin="608.2200" TopMargin="8.8440" BottomMargin="534.1560" ProgressInfo="100" ctype="LoadingBarObjectData">
                <Size X="381.0000" Y="33.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="225.2800" Y="550.6560" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.2200" Y="0.9560" />
                <PreSize X="0.0000" Y="0.0000" />
                <ImageFileData Type="Normal" Path="res/ui/battle/battle_scene_18.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="enemy_bar" ActionTag="1738379334" Tag="49" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="608.2200" RightMargin="34.7800" TopMargin="8.8440" BottomMargin="534.1560" ProgressInfo="100" ProgressType="Right_To_Left" ctype="LoadingBarObjectData">
                <Size X="381.0000" Y="33.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="798.7200" Y="550.6560" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.7800" Y="0.9560" />
                <PreSize X="0.0000" Y="0.0000" />
                <ImageFileData Type="Normal" Path="res/ui/battle/battle_scene_18.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_left_bar_bg" ActionTag="-1806503387" Tag="46" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" RightMargin="600.0000" BottomMargin="472.0000" Scale9Width="424" Scale9Height="104" ctype="ImageViewObjectData">
                <Size X="424.0000" Y="104.0000" />
                <Children>
                  <AbstractNodeData Name="player_name" ActionTag="-1086496329" Tag="52" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="53.2800" RightMargin="290.7200" TopMargin="50.9000" BottomMargin="30.1000" FontSize="20" LabelText="慕容晓安" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="80.0000" Y="23.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="93.2800" Y="41.6000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.2200" Y="0.4000" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <OutlineColor A="0" R="0" G="0" B="0" />
                    <ShadowColor A="0" R="0" G="0" B="0" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="p_skill_1" ActionTag="-1658990249" Tag="61" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="185.0000" RightMargin="185.0000" TopMargin="45.8000" BottomMargin="4.2000" Scale9Width="54" Scale9Height="54" ctype="ImageViewObjectData">
                    <Size X="54.0000" Y="54.0000" />
                    <Children>
                      <AbstractNodeData Name="p_skill_icon" ActionTag="1031648968" Tag="54" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="-14.0000" RightMargin="-14.0000" TopMargin="-14.5000" BottomMargin="-14.5000" Scale9Width="82" Scale9Height="83" ctype="ImageViewObjectData">
                        <Size X="82.0000" Y="83.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="27.0000" Y="27.0000" />
                        <Scale ScaleX="0.6100" ScaleY="0.6100" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="1.5185" Y="1.5370" />
                        <FileData Type="Normal" Path="res/items/skill/skill_10002.png" Plist="" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="212.0000" Y="31.2000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.3000" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FileData Type="Normal" Path="res/ui/battle/battle_scene_17.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="p_skill_2" ActionTag="-966132189" Tag="62" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="248.6000" RightMargin="121.4000" TopMargin="45.8000" BottomMargin="4.2000" Scale9Width="54" Scale9Height="54" ctype="ImageViewObjectData">
                    <Size X="54.0000" Y="54.0000" />
                    <Children>
                      <AbstractNodeData Name="p_skill_icon" ActionTag="1920771191" Tag="55" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="-14.0000" RightMargin="-14.0000" TopMargin="-14.5000" BottomMargin="-14.5000" Scale9Width="82" Scale9Height="83" ctype="ImageViewObjectData">
                        <Size X="82.0000" Y="83.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="27.0000" Y="27.0000" />
                        <Scale ScaleX="0.6100" ScaleY="0.6100" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="1.5185" Y="1.5370" />
                        <FileData Type="Normal" Path="res/items/skill/skill_10004.png" Plist="" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="275.6000" Y="31.2000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.6500" Y="0.3000" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FileData Type="Normal" Path="res/ui/battle/battle_scene_17.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="p_skill_3" ActionTag="-78547800" Tag="63" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="312.2000" RightMargin="57.8000" TopMargin="45.8000" BottomMargin="4.2000" Scale9Width="54" Scale9Height="54" ctype="ImageViewObjectData">
                    <Size X="54.0000" Y="54.0000" />
                    <Children>
                      <AbstractNodeData Name="p_skill_icon" ActionTag="-226441349" Tag="56" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="-14.0000" RightMargin="-14.0000" TopMargin="-14.5000" BottomMargin="-14.5000" Scale9Width="82" Scale9Height="83" ctype="ImageViewObjectData">
                        <Size X="82.0000" Y="83.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="27.0000" Y="27.0000" />
                        <Scale ScaleX="0.6100" ScaleY="0.6100" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="1.5185" Y="1.5370" />
                        <FileData Type="Normal" Path="res/items/skill/skill_10009.png" Plist="" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="339.2000" Y="31.2000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.8000" Y="0.3000" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FileData Type="Normal" Path="res/ui/battle/battle_scene_17.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleY="1.0000" />
                <Position Y="576.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition Y="1.0000" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="res/ui/battle/battle_scene_13.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_right_bar_bg" ActionTag="246750088" Tag="47" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="600.0000" BottomMargin="472.0000" Scale9Width="424" Scale9Height="104" ctype="ImageViewObjectData">
                <Size X="424.0000" Y="104.0000" />
                <Children>
                  <AbstractNodeData Name="enemy_name" ActionTag="-1464981544" Tag="53" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="300.7200" RightMargin="63.2800" TopMargin="50.9000" BottomMargin="30.1000" FontSize="20" LabelText="陈清韵" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="60.0000" Y="23.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="330.7200" Y="41.6000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.7800" Y="0.4000" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <OutlineColor A="0" R="0" G="0" B="0" />
                    <ShadowColor A="0" R="0" G="0" B="0" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="e_skill_1" ActionTag="-1078256264" Tag="64" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="185.0000" RightMargin="185.0000" TopMargin="45.8000" BottomMargin="4.2000" Scale9Width="54" Scale9Height="54" ctype="ImageViewObjectData">
                    <Size X="54.0000" Y="54.0000" />
                    <Children>
                      <AbstractNodeData Name="e_skill_icon" ActionTag="517262946" Tag="65" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="-14.0000" RightMargin="-14.0000" TopMargin="-14.5000" BottomMargin="-14.5000" Scale9Width="82" Scale9Height="83" ctype="ImageViewObjectData">
                        <Size X="82.0000" Y="83.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="27.0000" Y="27.0000" />
                        <Scale ScaleX="0.6100" ScaleY="0.6100" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="1.5185" Y="1.5370" />
                        <FileData Type="Normal" Path="res/items/skill/skill_10010.png" Plist="" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="212.0000" Y="31.2000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.3000" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FileData Type="Normal" Path="res/ui/battle/battle_scene_17.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="e_skill_2" ActionTag="-120697281" Tag="66" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="121.4000" RightMargin="248.6000" TopMargin="45.8000" BottomMargin="4.2000" Scale9Width="54" Scale9Height="54" ctype="ImageViewObjectData">
                    <Size X="54.0000" Y="54.0000" />
                    <Children>
                      <AbstractNodeData Name="e_skill_icon" ActionTag="1113512291" Tag="67" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="-14.0000" RightMargin="-14.0000" TopMargin="-14.5000" BottomMargin="-14.5000" Scale9Width="82" Scale9Height="83" ctype="ImageViewObjectData">
                        <Size X="82.0000" Y="83.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="27.0000" Y="27.0000" />
                        <Scale ScaleX="0.6100" ScaleY="0.6100" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="1.5185" Y="1.5370" />
                        <FileData Type="Normal" Path="res/items/skill/skill_10013.png" Plist="" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="148.4000" Y="31.2000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.3500" Y="0.3000" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FileData Type="Normal" Path="res/ui/battle/battle_scene_17.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="e_skill_3" ActionTag="339601224" Tag="68" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="57.8000" RightMargin="312.2000" TopMargin="45.8000" BottomMargin="4.2000" Scale9Width="54" Scale9Height="54" ctype="ImageViewObjectData">
                    <Size X="54.0000" Y="54.0000" />
                    <Children>
                      <AbstractNodeData Name="e_skill_icon" ActionTag="512577962" Tag="69" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="-14.0000" RightMargin="-14.0000" TopMargin="-14.5000" BottomMargin="-14.5000" Scale9Width="82" Scale9Height="83" ctype="ImageViewObjectData">
                        <Size X="82.0000" Y="83.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="27.0000" Y="27.0000" />
                        <Scale ScaleX="0.6100" ScaleY="0.6100" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="1.5185" Y="1.5370" />
                        <FileData Type="Normal" Path="res/items/skill/skill_10004.png" Plist="" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="84.8000" Y="31.2000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.2000" Y="0.3000" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FileData Type="Normal" Path="res/ui/battle/battle_scene_17.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="1.0000" ScaleY="1.0000" />
                <Position X="1024.0000" Y="576.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="1.0000" Y="1.0000" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="res/ui/battle/battle_scene_14.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_top_mid" ActionTag="1869361590" Tag="50" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="411.5000" RightMargin="411.5000" BottomMargin="495.0000" Scale9Width="201" Scale9Height="81" ctype="ImageViewObjectData">
                <Size X="201.0000" Y="81.0000" />
                <Children>
                  <AbstractNodeData Name="Text_time" ActionTag="787480469" Tag="51" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="70.5000" RightMargin="70.5000" TopMargin="18.4000" BottomMargin="34.6000" FontSize="24" LabelText="20:00" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="60.0000" Y="28.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="100.5000" Y="48.6000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.6000" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <OutlineColor A="0" R="0" G="0" B="0" />
                    <ShadowColor A="0" R="0" G="0" B="0" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="1.0000" />
                <Position X="512.0000" Y="576.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="1.0000" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="res/ui/battle/battle_scene_21.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="1.0000" />
            <Position X="512.0000" Y="576.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="1.0000" />
            <PreSize X="1.0000" Y="1.0000" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="Panel_down" ActionTag="719555500" Tag="60" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" BackColorAlpha="102" ColorAngle="90.0000" ctype="PanelObjectData">
            <Size X="1024.0000" Y="576.0000" />
            <Children>
              <AbstractNodeData Name="Image_nuqi" ActionTag="1046682487" Tag="71" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="899.6000" RightMargin="80.4000" TopMargin="493.4000" BottomMargin="32.6000" Scale9Width="44" Scale9Height="50" ctype="ImageViewObjectData">
                <Size X="44.0000" Y="50.0000" />
                <Children>
                  <AbstractNodeData Name="Text_nuqi_num" ActionTag="-1720854530" Tag="72" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="48.4000" RightMargin="-35.4000" TopMargin="8.0000" BottomMargin="8.0000" FontSize="30" LabelText="x3" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="31.0000" Y="34.0000" />
                    <AnchorPoint ScaleY="0.5000" />
                    <Position X="48.4000" Y="25.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="1.1000" Y="0.5000" />
                    <PreSize X="0.0000" Y="0.0000" />
                    <OutlineColor A="0" R="0" G="0" B="0" />
                    <ShadowColor A="0" R="0" G="0" B="0" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="921.6000" Y="57.6000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9000" Y="0.1000" />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="res/ui/battle/battle_scene_22.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="512.0000" Y="288.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameProjectFile>