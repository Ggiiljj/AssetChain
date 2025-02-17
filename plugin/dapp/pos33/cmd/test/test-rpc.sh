#!/usr/bin/env bash
# shellcheck disable=SC2128
set -e
set -o pipefail

MAIN_HTTP=""

# shellcheck source=/dev/null
source ../dapp-test-common.sh

ticketId=""
price=$((10000 * 100000000))

pos33_CreateBindMiner() {
    #创建交易
    minerAddr=$1
    returnAddr=$2
    returnPriv=$3
    amount=$4
    resp=$(curl -ksd '{"method":"pos33.CreateBindMiner","params":[{"bindAddr":"'"$minerAddr"'", "originAddr":"'"$returnAddr"'", "amount":'"$amount"', "checkBalance":true}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
    ok=$(echo "${resp}" | jq -r ".error")
    [[ $ok == null ]]
    rst=$?
    echo_rst "$FUNCNAME" "$rst"
    #发送交易
    rawTx=$(echo "${resp}" | jq -r ".result.txHex")
    chain33_SignRawTx "${rawTx}" "${returnPriv}" ${MAIN_HTTP}
}

# pos33_SetAutoMining() {
#     flag=$1
#     resp=$(curl -ksd '{"method":"pos33.SetAutoMining","params":[{"flag":'"$flag"'}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
#     ok=$(jq '(.error|not) and (.result.isOK == true)' <<<"$resp")
#     [[ $ok == true ]]
#     rst=$?
#     echo_rst "$FUNCNAME" "$rst"
# }

pos33_SetPos33Entrust() {
    consignee=$1
    consignor=$2
    amount=$3

    resp=$(curl -ksd '{"method":"pos33.SetPos33Entrust","params":[{"consignee":"'"$consignee"'", "consignor":"'"$consignor"'", "amount":"'"$amount"'"}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
    ok=$(jq '(.error|not) and (.result > 0)' <<<"$resp")
    [[ $ok == true ]]
    rst=$?
    echo_rst "$FUNCNAME" "$rst"
}

pos33_GetConsigneeEntrust() {
    addr=$1
    resp=$(curl -ksd '{"method":"pos33.GetPos33ConsigneeEntruct","params":[{"addr":"'"$addr"'"}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
    ok=$(jq '(.error|not) and (.result > 0)' <<<"$resp")
    [[ $ok == true ]]
    rst=$?
    echo_rst "$FUNCNAME" "$rst"
}

pos33_GetConsignorEntrust() {
    addr=$1
    resp=$(curl -ksd '{"method":"pos33.GetPos33ConsignorEntruct","params":[{"addr":"'"$addr"'"}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
    ok=$(jq '(.error|not) and (.result > 0)' <<<"$resp")
    [[ $ok == true ]]
    rst=$?
    echo_rst "$FUNCNAME" "$rst"
}

pos33_GetPos33TicketCount() {
    addr=$1
    resp=$(curl -ksd '{"method":"pos33.GetPos33TicketCount","params":[{"addr":"'"$addr"'"}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
    ok=$(jq '(.error|not) and (.result > 0)' <<<"$resp")
    [[ $ok == true ]]
    rst=$?
    echo_rst "$FUNCNAME" "$rst"
}

pos33_GetAllPos33TicketCount() {
    resp=$(curl -ksd '{"method":"pos33.GetAllPos33TicketCount","params":[{}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
    ok=$(jq '(.error|not) and (.result > 0)' <<<"$resp")
    [[ $ok == true ]]
    rst=$?
    echo_rst "$FUNCNAME" "$rst"
}

# pos33_ClosePos33Tickets() {
#     addr=$1
#     resp=$(curl -ksd '{"method":"pos33.ClosePos33Tickets","params":[{"minerAddress":"'"$addr"'"}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
#     ok=$(jq '(.error|not)' <<<"$resp")
#     [[ $ok == true ]]
#     rst=$?
#     echo_rst "$FUNCNAME" "$rst"
# }

# pos33_Pos33TicketInfos() {
#     tid=$1
#     minerAddr=$2
#     returnAddr=$3
#     execer="pos33"
#     funcName="Pos33TicketInfos"
#     resp=$(curl -ksd '{"method":"Chain.Query","params":[{"execer":"'"$execer"'","funcName":"'"$funcName"'","payload":{"ticketIds":["'"$tid"'"]}}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
#     ok=$(jq '(.error|not) and (.result.tickets | length > 0) and (.result.tickets[0].minerAddress == "'"$minerAddr"'") and (.result.tickets[0].returnAddress == "'"$returnAddr"'")' <<<"$resp")
#     [[ $ok == true ]]
#     rst=$?
#     echo_rst "$FUNCNAME" "$rst"
# }

# pos33_Pos33TicketList() {
#     minerAddr=$1
#     returnAddr=$2
#     status=$3
#     execer="pos33"
#     funcName="Pos33TicketList"
#     resp=$(curl -ksd '{"method":"Chain.Query","params":[{"execer":"'"$execer"'","funcName":"'"$funcName"'","payload":{"addr":"'"$minerAddr"'", "status":'"$status"'}}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
#     ok=$(jq '(.error|not) and (.result.tickets | length > 0) and (.result.tickets[0].minerAddress == "'"$minerAddr"'") and (.result.tickets[0].returnAddress == "'"$returnAddr"'") and (.result.tickets[0].status == '"$status"')' <<<"$resp")
#     [[ $ok == true ]]
#     rst=$?
#     echo_rst "$FUNCNAME" "$rst"

#     ticket0=$(echo "${resp}" | jq -r ".result.tickets[0]")
#     echo -e "######\\n  ticket[0] is $ticket0)  \\n######"
#     ticketId=$(echo "${resp}" | jq -r ".result.tickets[0].ticketId")
#     echo -e "######\\n  ticketId is $ticketId  \\n######"
# }

# pos33_MinerAddress() {
#     returnAddr=$1
#     minerAddr=$2
#     execer="pos33"
#     funcName="MinerAddress"
#     resp=$(curl -ksd '{"method":"Chain.Query","params":[{"execer":"'"$execer"'","funcName":"'"$funcName"'","payload":{"data":"'"$returnAddr"'"}}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
#     ok=$(jq '(.error|not) and (.result.data == "'"$minerAddr"'")' <<<"$resp")
#     [[ $ok == true ]]
#     rst=$?
#     echo_rst "$FUNCNAME" "$rst"
# }

# pos33_MinerSourceList() {
#     minerAddr=$1
#     returnAddr=$2
#     execer="pos33"
#     funcName="MinerSourceList"
#     resp=$(curl -ksd '{"method":"Chain.Query","params":[{"execer":"'"$execer"'","funcName":"'"$funcName"'","payload":{"data":"'"$minerAddr"'"}}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
#     ok=$(jq '(.error|not) and (.result.datas | length > 0) and (.result.datas[0] == "'"$returnAddr"'")' <<<"$resp")
#     [[ $ok == true ]]
#     rst=$?
#     echo_rst "$FUNCNAME" "$rst"
# }

# # pos33_RandNumHash() {
# #     hash=$1
# #     blockNum=$2
# #     execer="pos33"
# #     funcName="RandNumHash"
# #     resp=$(curl -ksd '{"method":"Chain.Query","params":[{"execer":"'"$execer"'","funcName":"'"$funcName"'","payload":{"hash":"'"$hash"'", "blockNum":'"$blockNum"'}}]}' -H 'content-type:text/plain;' ${MAIN_HTTP})
# #     ok=$(jq '(.error|not) and (.result.hash != "")' <<<"$resp")
# #     [[ $ok == true ]]
# #     rst=$?
# #     echo_rst "$FUNCNAME" "$rst"
# # }

# function run_testcases() {
#     #账户地址
#     minerAddr1="1PUiGcbsccfxW3zuvHXZBJfznziph5miAo"
#     returnAddr1="1EbDHAXpoiewjPLX9uqoz38HsKqMXayZrF"

#     minerAddr2="12HKLEn6g4FH39yUbHh4EVJWcFo5CXg22d"

#     returnAddr2="1NNaYHkscJaLJ2wUrFNeh6cQXBS4TrFYeB"
#     returnPriv2="0x794443611e7369a57b078881445b93b754cbc9b9b8f526535ab9c6d21d29203d"

#     chain33_QueryBalance "${returnAddr2}" "${MAIN_HTTP}"
#     chain33_applyCoins "${minerAddr2}" 1000000000 "${MAIN_HTTP}"

#     pos33_SetAutoMining 0
#     pos33_GetPos33TicketCount
#     pos33_Pos33TicketList "${minerAddr1}" "${returnAddr1}" 1
#     pos33_Pos33TicketInfos "${ticketId}" "${minerAddr1}" "${returnAddr1}"
#     #购票
#     pos33_CreateBindMiner "${minerAddr2}" "${returnAddr2}" "${returnPriv2}" ${price}
#     pos33_MinerAddress "${returnAddr2}" "${minerAddr2}"
#     pos33_MinerSourceList "${minerAddr2}" "${returnAddr2}"
#     #关闭
#     pos33_ClosePos33Tickets "${minerAddr1}"

#     chain33_LastBlockhash "${MAIN_HTTP}"
#     pos33_RandNumHash "${LAST_BLOCK_HASH}" 5
# }

function main() {
    chain33_RpcTestBegin Pos33Ticket
    MAIN_HTTP="$1"
    echo "main_ip=$MAIN_HTTP"

    ispara=$(echo '"'"${MAIN_HTTP}"'"' | jq '.|contains("8901")')
    if [[ $ispara == true ]]; then
        echo "***skip ticket test on parachain***"
    else
        echo "***skip ticket test on pos33 ***"
        # run_testcases
    fi

    chain33_RpcTestRst Pos33Ticket "$CASE_ERR"
}

chain33_debug_function main "$1"
