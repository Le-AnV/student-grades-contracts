// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./AccessControlManager.sol";

contract StudentManager is AccessControlManager {
    struct Student {
        string studentId;
        string name;
        address wallet;
        bool active;
    }

    mapping(address => Student) private studentsByWallet;
    mapping(bytes32 => address) private walletByStudentIdHash;

    event StudentAdded(string studentId, address wallet, string name);
    event StudentDeactivated(address wallet);

    function addStudent(
        string calldata studentId,
        address wallet,
        string calldata name
    ) external onlyTeacherOrAdmin {
        require(wallet != address(0), "Invalid wallet");

        bytes32 idHash = keccak256(bytes(studentId));
        require(walletByStudentIdHash[idHash] == address(0), "StudentId exists");
        require(studentsByWallet[wallet].wallet == address(0), "Wallet already registered");

        studentsByWallet[wallet] = Student({
            studentId: studentId,
            name: name,
            wallet: wallet,
            active: true
        });

        walletByStudentIdHash[idHash] = wallet;

        // auto grant student role
        _grantRole(STUDENT_ROLE, wallet);

        emit StudentAdded(studentId, wallet, name);
    }

    function deactivateStudent(address wallet) external onlyAdmin {
        require(studentsByWallet[wallet].wallet != address(0), "Student not found");
        studentsByWallet[wallet].active = false;
        emit StudentDeactivated(wallet);
    }

    function getStudent(address wallet) external view returns (Student memory) {
        require(
            msg.sender == wallet || hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(TEACHER_ROLE, msg.sender),
            "Not allowed"
        );
        require(studentsByWallet[wallet].wallet != address(0), "Student not found");
        return studentsByWallet[wallet];
    }

    function getStudentById(string calldata studentId) external view returns (Student memory) {
        bytes32 idHash = keccak256(bytes(studentId));
        address wallet = walletByStudentIdHash[idHash];
        require(wallet != address(0), "Student not found");
        return studentsByWallet[wallet];
    }

    function isStudentActive(address wallet) external view returns (bool) {
        return studentsByWallet[wallet].active;
    }

    function isStudentRegistered(address wallet) external view returns (bool) {
        return studentsByWallet[wallet].wallet != address(0);
    }
}