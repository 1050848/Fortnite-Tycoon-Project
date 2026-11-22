
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

tycoon_player_data := class<final><persistable>:
    Cash:int = 100
    Income:int = 10
    UpgradeCost:int = 50

var TycoonPlayerData:weak_map(player, tycoon_player_data) = map{}

tycoon_manager := class(creative_device):

    @editable
    CollectButton:button_device = button_device{}

    @editable
    UpgradeButton:button_device = button_device{}

    OnBegin<override>()<suspends>:void=
        CollectButton.InteractedWithEvent.Subscribe(CollectCash)
        UpgradeButton.InteractedWithEvent.Subscribe(BuyUpgrade)

        for (Player : GetPlayspace().GetPlayers()):
            InitializePlayer(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(InitializePlayer)

    InitializePlayer(Player:player):void=
        if (ExistingData := TycoonPlayerData[Player]):
            Print("Player data loaded.")
        else:
            if (set TycoonPlayerData[Player] = tycoon_player_data{}):
                Print("New player initialized with $100.")

    CollectCash(Agent:agent):void=
        if (Player := player[Agent]):
            if (Data := TycoonPlayerData[Player]):
                NewData := tycoon_player_data:
                    Cash := Data.Cash + Data.Income
                    Income := Data.Income
                    UpgradeCost := Data.UpgradeCost

                if (set TycoonPlayerData[Player] = NewData):
                    Print("Cash collected!")
                    
    BuyUpgrade(Agent:agent):void=
        if (Player := player[Agent]):
            if (Data := TycoonPlayerData[Player]):
                if (Data.Cash >= Data.UpgradeCost):
                    NewData := tycoon_player_data:
                        Cash := Data.Cash - Data.UpgradeCost
                        Income := Data.Income + 25
                        UpgradeCost := Data.UpgradeCost + 50

                    if (set TycoonPlayerData[Player] = NewData):
                        Print("Upgrade purchased!")
                else:
                    Print("Not enough cash!")