// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./AccessControlManager.sol";

interface IStudentManager {
    function isStudentActive(address wallet) external view returns (bool);
    function isStudentRegistered(address wallet) external view returns (bool);
}

contract ScoreManager is AccessControlManager {
    struct Score {
        uint256 value;
        uint256 createdAt;
        uint256 updatedAt;
        bool exists;
    }

    uint256 public constant EDIT_WINDOW = 10 minutes;

    IStudentManager public studentManager;

    // studentWallet => subjectHash => Score
    mapping(address => mapping(bytes32 => Score)) private scores;

    event ScoreCreated(address indexed student, string subject, uint256 value);
    event ScoreUpdated(address indexed student, string subject, uint256 value);

    constructor(address studentManagerAddress) {
        studentManager = IStudentManager(studentManagerAddress);
    }

    function setScore(
        address studentWallet,
        string calldata subject,
        uint256 value
    ) external onlyTeacherOrAdmin {
        require(studentWallet != address(0), "Invalid student wallet");
        require(studentManager.isStudentRegistered(studentWallet), "Student not registered");
        require(studentManager.isStudentActive(studentWallet), "Student inactive");

        bytes32 subjectHash = keccak256(bytes(subject));
        Score storage s = scores[studentWallet][subjectHash];

        if (!s.exists) {
            scores[studentWallet][subjectHash] = Score({
                value: value,
                createdAt: block.timestamp,
                updatedAt: block.timestamp,
                exists: true
            });

            emit ScoreCreated(studentWallet, subject, value);
        } else {
            require(block.timestamp <= s.createdAt + EDIT_WINDOW, "Edit window expired");

            s.value = value;
            s.updatedAt = block.timestamp;

            emit ScoreUpdated(studentWallet, subject, value);
        }
    }

    function getScore(
        address studentWallet,
        string calldata subject
    ) external view returns (Score memory) {
        require(
            msg.sender == studentWallet ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
                hasRole(TEACHER_ROLE, msg.sender),
            "Not allowed"
        );

        bytes32 subjectHash = keccak256(bytes(subject));
        Score memory s = scores[studentWallet][subjectHash];
        require(s.exists, "Score not found");
        return s;
    }

    function getMyScore(string calldata subject) external view returns (Score memory) {
        bytes32 subjectHash = keccak256(bytes(subject));
        Score memory s = scores[msg.sender][subjectHash];
        require(s.exists, "Score not found");
        return s;
    }
}