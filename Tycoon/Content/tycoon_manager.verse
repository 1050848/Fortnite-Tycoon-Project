using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }

CashMessage<localizes>(Cash:int, Income:int):message =
    "Cash: ${Cash}\nIncome: ${Income} per collection"

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

    @editable
    PassiveIncomeAmount:int = 5

    @editable
    PassiveIncomeInterval:float = 5.0

    var CashDisplays:[player]text_block = map{}

    OnBegin<override>()<suspends>:void=
        CollectButton.InteractedWithEvent.Subscribe(CollectCash)
        UpgradeButton.InteractedWithEvent.Subscribe(BuyUpgrade)

        for (Player : GetPlayspace().GetPlayers()):
            InitializePlayer(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(InitializePlayer)

        spawn{PassiveIncomeLoop()}

    InitializePlayer(Player:player):void=
        if (ExistingData := TycoonPlayerData[Player]):
            Print("Player data loaded.")
        else:
            if (set TycoonPlayerData[Player] = tycoon_player_data{}):
                Print("New player initialized.")

       if (PlayerUI := GetPlayerUI[Player]):
            if (Data := TycoonPlayerData[Player]):
                CashText := text_block{
                    DefaultText := CashMessage(100, 10)
                }

                PlayerUI.AddWidget(CashText)

                if (set CashDisplays[Player] = CashText):
                    Print("Cash display created.")

    UpdateCashDisplay(Player:player, Data:tycoon_player_data):void=
        if (CashText := CashDisplays[Player]):
            CashText.SetText(CashMessage(Data.Cash, Data.Income))

    CollectCash(Agent:agent):void=
        if (Player := player[Agent]):
            if (Data := TycoonPlayerData[Player]):
                NewData := tycoon_player_data{
                    Cash := Data.Cash + Data.Income
                    Income := Data.Income
                    UpgradeCost := Data.UpgradeCost
                }

                if (set TycoonPlayerData[Player] = NewData):
                    UpdateCashDisplay(Player, NewData)
                    Print("Cash collected!")
                    
    BuyUpgrade(Agent:agent):void=
        if (Player := player[Agent]):
            if (Data := TycoonPlayerData[Player]):
                if (Data.Cash >= Data.UpgradeCost):
                    NewData := tycoon_player_data{
                        Cash := Data.Cash - Data.UpgradeCost
                        Income := Data.Income + 25
                        UpgradeCost := Data.UpgradeCost + 50
                    }

                    if (set TycoonPlayerData[Player] = NewData):
                        UpdateCashDisplay(Player, NewData)
                        Print("Upgrade purchased!")
                else:
                    Print("Not enough cash!")

    PassiveIncomeLoop()<suspends>:void=
        loop:
            Sleep(PassiveIncomeInterval)

            for (Player : GetPlayspace().GetPlayers()):
                GrantPassiveIncome(Player)

    GrantPassiveIncome(Player:player):void=
        if (Data := TycoonPlayerData[Player]):
            NewData := tycoon_player_data{
                Cash := Data.Cash + PassiveIncomeAmount
                Income := Data.Income
                UpgradeCost := Data.UpgradeCost
            }

            if (set TycoonPlayerData[Player] = NewData):
                UpdateCashDisplay(Player, NewData)