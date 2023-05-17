$(function () {
    var sName, sColor, sParkIn, sParkOut, sAction, sSearch, state, open;

    function display(bool) {
        if(bool) {
            $(".app").show();
            var open = 1;
        } else {
            var open = 0;
            $(".app").hide();
            $("#garage").hide();
            $("#rename").hide();
        }
    }

    function openGarage(name, color, cParkIn, cParkOut, cAction, cSearch) {
        sName = name; sColor = color; sParkIn = cParkIn; sParkOut = cParkOut; sAction = cAction; sSearch = cSearch;
        display(true);
        
        $('#vehDescription').css("border", "1px solid " + sColor);
        $("#select2").css("border-left", "0px solid " + sColor).css("color", "whitesmoke");
        $('#select1').css("border-left", "5px solid " + sColor).css("color", sColor);
        $("#garage").css("display", "flex");
        $("#image").css("fill", color);
        $("#quit-icon").css("color", color);
        $("#border").css("border-bottom", "solid 2px " + color);
        

        const allItems = document.querySelectorAll('#car-icon');
        allItems.forEach(element => {
            $(element).css("color", color);
        })
        state = 0;
    
        $("#row").empty();
        $("#title").empty();
        $("#select1").addClass("active");
        $("#select2").removeClass("active");
        $("#park-in").empty();
        $("#park-out").empty();
        $("#search").val('');
        $("#action").empty();
        $("#current_page").empty();
        $("#interButton").empty();

        $("#park-in").append(sParkIn);
        $("#title").append(name);
        $("#park-out").append(sParkOut);
        $("#action").append(sAction);
        $("#interButton").append('<i class="fas fa-car"></i> ' + sParkIn);
        $("#current_page").append(sParkIn);
        $("#search").attr("placeholder", cSearch);

        var yx = document.getElementsByClassName("selected-vehicle");
        $(yx).removeClass("selected-vehicle");  
        showNextVehicles();
    }

    function openRename(color, nametag) {
        display(true);
        $("#renameButton").css("background-color", color);
        $("#rename").css("display", "flex");
        $("#garageTitle").css("border-bottom", "1px solid " + color);
        $("#vehDescription").val(nametag);
    }

    display(false)
    window.addEventListener("message", function(event) {
        var item = event.data;
        if(item.type === "garage") {
            if(item.call == true) openGarage(item.name, item.color, item.park_in_name, item.park_out_name, item.action_name, item.search_name); $("body").append('<style type="text/css">::-webkit-scrollbar {width: 1px;height: 1px;}::-webkit-scrollbar-button {width: 0px;height: 0px;}::-webkit-scrollbar-thumb {background: ' + sColor + ';::-webkit-scrollbar-button{width:0;height:0}::-webkit-scrollbar-thumb{background:' + sColor + ';border:0 none #fff;border-radius:0}::-webkit-scrollbar-thumb:hover{background:' + sColor + '}::-webkit-scrollbar-thumb:active{background:' + sColor + '}::-webkit-scrollbar-track{background:#4d4d4d;border:0 none #fff;border-radius:0}::-webkit-scrollbar-track:hover{background:' + sColor + '}::-webkit-scrollbar-track:active{background:#333}::-webkit-scrollbar-corner{background:0 0}</style>');
        } else if(item.type === "rename") {
            if(item.call === true) openRename(item.color, item.cNameTag);
        } else if(item.type === "window") {
            if(item.call === false) display(false);
        } else if(item.type === "addStoredVehicle") { 
            if(item.id === null) item.id = "?";
            $("#row").append('<div class="car-container" id="vehicleCon" data-plate="' + item.plate + '"><div class="picture"><i id="car-icon" class="fas fa-car" style="font-size: 50px;"></i></div><div style="width: 1px; height: 50px; margin-top: 15px; margin-right: 12.5px; background-color: rgb(119, 119, 119);"></div><div class="info"><a style="font-size: 15px;">' + item.name + '</a><p style="font-size: 12px; margin-top: -5px;"><a id="">' + item.id + '</a> <a>(' + item.nametag + ')</a></p></div></div>');
            const allItems = document.querySelectorAll('#car-icon');
            allItems.forEach(element => {
                $(element).css("color", sColor);
            })
        }
    })

    document.onkeyup = function(data) {
        if(data.which == 27) {
            if(open != 1) $.post("https://nk_garage/exit", JSON.stringify({}));
        }
    }

    $("#close").click(function() {
        if(open != 1) $.post("https://nk_garage/exit", JSON.stringify({}));
    })

    $("#in").click(function switchToIn() {
        if(state == 0) return;
        var x = document.getElementsByClassName("active");
        $("#select2").css("border-left", "0px solid " + sColor).css("color", "whitesmoke");
        $('#select1').css("border-left", "5px solid " + sColor).css("color", sColor);
        $("#select1").addClass("active");
        $("#select2").removeClass("active");
        $("#current_page").empty();
        $("#interButton").empty();
        $("#interButton").append('<i class="fas fa-car"></i> ' + sParkIn);
        $("#current_page").append(sParkIn);
        $("#search").val('');
        var yx = document.getElementsByClassName("selected-vehicle");
        $(yx).removeClass("selected-vehicle");  
        $("#row").empty();
        state = 0;
        showNextVehicles();
    })

    $("#out").click(function switchToOut() {
        if(state == 1) return;
        var x = document.getElementsByClassName("active");
        $("#select1").css("border-left", "0px solid " + sColor).css("color", "whitesmoke");
        $("#select2").css("border-left", "5px solid " + sColor).css("color", sColor);
        
        $("#select2").addClass("active");
        $("#select1").removeClass("active");
        $("#current_page").empty();
        $("#interButton").empty();
        $("#interButton").append('<i class="fas fa-car"></i> ' + sParkOut);
        $("#current_page").append(sParkOut);
        $("#search").val('');
        var yx = document.getElementsByClassName("selected-vehicle");
        $(yx).removeClass("selected-vehicle");  
        $("#row").empty();
        state = 1;
        showStoredVehicles();
    })

    $("#renameButton").click(function() {
        $.post("https://nk_garage/nk_garage:setVehicleName", JSON.stringify({
            nameFromCurrentVehicle: $('#vehDescription').val()
        }));
        if(open != 1) $.post("https://nk_garage/exit", JSON.stringify({}));
    })

    $('#row').on('click', '.car-container', function(e) {
        var x = document.getElementsByClassName("selected-vehicle");
        $(x).removeClass("selected-vehicle");
        $(this).addClass("selected-vehicle");
    })

    $('#interButton').click(function() {
        var x = document.getElementsByClassName("selected-vehicle");

        if($(x).attr('id') == "vehicleCon") {
            if(state == 1) {
                $.post("https://nk_garage/nk_garage:spawnVehicle", JSON.stringify({
                    selectedPlate: $(x).data("plate")
                }))
                $.post("https://nk_garage/exit", JSON.stringify({}));
            } else {
                $.post("https://nk_garage/nk_garage:removeVehicle", JSON.stringify({
                    selectedPlate: $(x).data("plate")
                }))
                $.post("https://nk_garage/exit", JSON.stringify({}));
            }
        }

    })

    function showStoredVehicles() {
        $.post("https://nk_garage/nk_garage:rowStoredVehicles", JSON.stringify({}));
    }

    function showNextVehicles() {
        $.post("https://nk_garage/nk_garage:rowNextVehicles", JSON.stringify({}));
    }

})