// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HealthInsuranceFraudDetection {

    struct Policy {
        address insured;
        string policyId;
        bool isActive;
    }

    struct Claim {
        string claimId;
        string policyId;
        uint256 date;
        string serviceCode;
        uint256 amount;
        bool approved;
        bool exists;
    }

    mapping(string => Policy) public policies;
    mapping(string => Claim) public claims;
    mapping(string => bool) private processedClaims;

    event ClaimSubmitted(string claimId, string policyId, uint256 amount);
    event ClaimApproved(string claimId);
    event FraudAlert(string claimId, string reason);

    function registerPolicy(string memory _policyId, address _insured) public {
        policies[_policyId] = Policy(_insured, _policyId, true);
    }

    function submitClaim(
        string memory _claimId,
        string memory _policyId,
        uint256 _date,
        string memory _serviceCode,
        uint256 _amount
    ) public {
        require(policies[_policyId].isActive, "Policy is not active");
        require(!claims[_claimId].exists, "Duplicate claim ID");

        string memory claimKey = string(abi.encodePacked(_policyId, _date, _serviceCode));
        if (processedClaims[claimKey]) {
            emit FraudAlert(_claimId, "Duplicate service claim detected");
        }

        claims[_claimId] = Claim(_claimId, _policyId, _date, _serviceCode, _amount, false, true);
        processedClaims[claimKey] = true;

        emit ClaimSubmitted(_claimId, _policyId, _amount);
    }

    function approveClaim(string memory _claimId) public {
        require(claims[_claimId].exists, "Claim does not exist");
        claims[_claimId].approved = true;

        emit ClaimApproved(_claimId);
    }
}
