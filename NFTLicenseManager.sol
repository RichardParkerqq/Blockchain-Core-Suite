// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NFTLicenseManager {
    struct License {
        uint256 tokenId;
        address licensor;
        address licensee;
        uint256 expiry;
        bool active;
    }

    mapping(uint256 => License) public licenses;
    uint256 public licenseCount;

    event LicenseCreated(uint256 indexed id, uint256 tokenId, address licensee);
    event LicenseRevoked(uint256 indexed id);

    function createLicense(uint256 _tokenId, address _licensee, uint256 _duration) external returns (uint256) {
        licenseCount++;
        licenses[licenseCount] = License(
            _tokenId,
            msg.sender,
            _licensee,
            block.timestamp + _duration,
            true
        );
        emit LicenseCreated(licenseCount, _tokenId, _licensee);
        return licenseCount;
    }

    function revokeLicense(uint256 _id) external {
        License storage l = licenses[_id];
        require(l.licensor == msg.sender && l.active, "Not authorized");
        l.active = false;
        emit LicenseRevoked(_id);
    }

    function isLicenseValid(uint256 _id) external view returns (bool) {
        License storage l = licenses[_id];
        return l.active && block.timestamp < l.expiry;
    }
}
