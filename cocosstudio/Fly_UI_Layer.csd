<GameProjectFile>
  <PropertyGroup Type="Layer" Name="Fly_UI_Layer" ID="856a56c2-b875-418d-8ccd-e295e18ca4df" Version="2.3.2.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Layer" Tag="12" ctype="GameLayerObjectData">
        <Size X="1024.0000" Y="576.0000" />
        <Children>
          <AbstractNodeData Name="bgPanel" ActionTag="1929817668" Tag="275" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" TouchEnable="True" ComboBoxIndex="1" ColorAngle="90.0000" ctype="PanelObjectData">
            <Size X="1024.0000" Y="576.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="512.0000" Y="288.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <SingleColor A="255" R="0" G="0" B="0" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="Panel" ActionTag="871904343" Tag="13" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" TouchEnable="True" BackColorAlpha="151" ColorAngle="90.0000" ctype="PanelObjectData">
            <Size X="1024.0000" Y="576.0000" />
            <Children>
              <AbstractNodeData Name="bg" ActionTag="-1276641355" Tag="14" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="19.7800" RightMargin="81.2200" TopMargin="22.0000" BottomMargin="22.0000" ctype="SpriteObjectData">
                <Size X="923.0000" Y="532.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="481.2800" Y="288.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4700" Y="0.5000" />
                <PreSize X="0.9463" Y="0.9913" />
                <FileData Type="Normal" Path="ui/FlyUI/bg.png" Plist="" />
                <BlendFunc Src="1" Dst="771" />
              </AbstractNodeData>
              <AbstractNodeData Name="titleBg" ActionTag="-1307946536" Tag="122" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="76.9000" RightMargin="640.1000" TopMargin="4.5600" BottomMargin="511.4400" ctype="SpriteObjectData">
                <Size X="307.0000" Y="60.0000" />
                <Children>
                  <AbstractNodeData Name="Text_Name" ActionTag="-1619378407" Tag="573" IconVisible="False" LeftMargin="80.2474" RightMargin="106.7526" TopMargin="9.4622" BottomMargin="16.5378" FontSize="30" LabelText="飞宝管理" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="120.0000" Y="34.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="140.2474" Y="33.5378" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="173" G="199" B="255" />
                    <PrePosition X="0.4568" Y="0.5590" />
                    <PreSize X="0.2606" Y="0.3667" />
                    <FontResource Type="Normal" Path="TTF/FZY3JW.TTF" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="230.4000" Y="541.4400" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.2250" Y="0.9400" />
                <PreSize X="0.2998" Y="0.1007" />
                <FileData Type="Normal" Path="ui/godwill/godwill_new/public/titleBg.png" Plist="" />
                <BlendFunc Src="1" Dst="771" />
              </AbstractNodeData>
              <AbstractNodeData Name="exitBtn" ActionTag="129299528" Tag="54" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="906.3400" RightMargin="66.6600" TopMargin="11.4400" BottomMargin="512.5600" TouchEnable="True" FontSize="14" Scale9Enable="True" Scale9Width="51" Scale9Height="52" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="51.0000" Y="52.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="931.8400" Y="538.5600" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9100" Y="0.9350" />
                <PreSize X="0.0498" Y="0.0903" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="ui/townAssignment/button_close.png" Plist="" />
                <PressedFileData Type="Normal" Path="ui/townAssignment/button_close.png" Plist="" />
                <NormalFileData Type="Normal" Path="ui/townAssignment/button_close.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="allviewBtn" ActionTag="173996865" Tag="15" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="939.9264" RightMargin="16.0736" TopMargin="96.2808" BottomMargin="374.7192" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="38" Scale9Height="83" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="68.0000" Y="105.0000" />
                <Children>
                  <AbstractNodeData Name="allViewTitle" ActionTag="1896436190" Tag="498" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="18.5000" RightMargin="18.5000" TopMargin="23.0000" BottomMargin="23.0000" ctype="SpriteObjectData">
                    <Size X="31.0000" Y="59.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="34.0000" Y="52.5000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.5000" />
                    <PreSize X="0.3906" Y="0.5701" />
                    <FileData Type="Normal" Path="ui/FlyUI/allViewTitle_2.png" Plist="" />
                    <BlendFunc Src="1" Dst="771" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="973.9264" Y="427.2192" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9511" Y="0.7417" />
                <PreSize X="0.0664" Y="0.1823" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="ui/FlyUI/itemBtn_2.png" Plist="" />
                <PressedFileData Type="Normal" Path="ui/FlyUI/itemBtn_2.png" Plist="" />
                <NormalFileData Type="Normal" Path="ui/FlyUI/itemBtn_1.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="flytechBtn" ActionTag="755241462" Tag="11" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="939.9264" RightMargin="16.0736" TopMargin="223.9800" BottomMargin="247.0200" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="38" Scale9Height="83" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="68.0000" Y="105.0000" />
                <Children>
                  <AbstractNodeData Name="flytechTitle" ActionTag="-822129834" Tag="499" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="18.0000" RightMargin="18.0000" TopMargin="24.0000" BottomMargin="24.0000" ctype="SpriteObjectData">
                    <Size X="32.0000" Y="57.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="34.0000" Y="52.5000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.5000" />
                    <PreSize X="0.0254" Y="0.1007" />
                    <FileData Type="Normal" Path="ui/FlyUI/FlyTechTitle_2.png" Plist="" />
                    <BlendFunc Src="1" Dst="771" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="973.9264" Y="299.5200" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9511" Y="0.5200" />
                <PreSize X="0.0664" Y="0.1823" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="ui/FlyUI/itemBtn_2.png" Plist="" />
                <PressedFileData Type="Normal" Path="ui/FlyUI/itemBtn_2.png" Plist="" />
                <NormalFileData Type="Normal" Path="ui/FlyUI/itemBtn_1.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="512.0000" Y="288.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <SingleColor A="255" R="26" G="26" B="26" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="handTo" ActionTag="-1292888377" Tag="622" IconVisible="True" RightMargin="1024.0000" TopMargin="576.0000" ctype="SingleNodeObjectData">
            <Size X="0.0000" Y="0.0000" />
            <AnchorPoint />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameProjectFile>