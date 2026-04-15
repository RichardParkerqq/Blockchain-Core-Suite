// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DecentralizedStorage {
    struct FileData {
        bytes32 cid;
        uint256 uploadTime;
        address uploader;
        string fileType;
    }

    mapping(bytes32 => FileData) public files;
    mapping(address => bytes32[]) public userFiles;
    uint256 public fileCount;

    event FileUploaded(bytes32 indexed cid, address indexed uploader, string fileType);

    function uploadFile(bytes32 _cid, string calldata _type) external {
        require(files[_cid].uploader == address(0), "Duplicate file");
        fileCount++;
        files[_cid] = FileData(
            _cid,
            block.timestamp,
            msg.sender,
            _type
        );
        userFiles[msg.sender].push(_cid);
        emit FileUploaded(_cid, msg.sender, _type);
    }

    function getFile(bytes32 _cid) external view returns (FileData memory) {
        return files[_cid];
    }

    function getUserFiles(address _user) external view returns (bytes32[] memory) {
        return userFiles[_user];
    }

    function fileExists(bytes32 _cid) external view returns (bool) {
        return files[_cid].uploader != address(0);
    }
}
