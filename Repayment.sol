pragma solidity ^0.8.0;

contract Crowdfunding {
    // Définition de la campagne
    uint public goalAmount;
    uint public deadline;
    uint public collectedAmount;
    mapping (address => uint) public contributions;

    // État de la campagne
    bool public isCampaignActive = true;

    // Événement pour les contributions et le remboursement
    event NewContribution(address contributor, uint amount);
    event CampaignFailed();

    constructor(uint _goalAmount, uint _deadline) public {
        goalAmount = _goalAmount;
        deadline = block.timestamp + _deadline;
    }

    // Fonction pour contribuer
    function contribute() public payable {
        require(isCampaignActive, "La campagne est terminée.");
        require(block.timestamp < deadline, "Délai dépassé.");

        contributions[msg.sender] += msg.value;
        collectedAmount += msg.value;
        emit NewContribution(msg.sender, msg.value);

        // Vérifier si l'objectif est atteint
        if (collectedAmount >= goalAmount) {
            isCampaignActive = false;
        }
    }

    // Fonction pour rembourser si l'objectif n'est pas atteint
    function checkCampaignStatus() public {
        require(block.timestamp >= deadline, "Le délai n'est pas encore dépassé.");
        require(isCampaignActive, "La campagne a déjà atteint son objectif ou a été clôturée.");

        if (collectedAmount < goalAmount) {
            // Rembourser les contributeurs
            for (address contributor in contributions) {
                contributor.transfer(contributions[contributor]);
            }
            emit CampaignFailed();
            isCampaignActive = false;
        }
    }

    // Fonction pour afficher l'état de la campagne
    function getCampaignStatus() public view returns (uint, uint, bool) {
        return (collectedAmount, deadline - block.timestamp, isCampaignActive);
    }
}
