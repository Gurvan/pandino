//Toggle advanced functions
function display_advanced() {
    if (document.getElementById('advanced').style.display == 'block') {
        document.getElementById('advanced').style.display = 'none';
    } else {
        document.getElementById('advanced').style.display = 'block';
    }
}


$(function() {
    $("h1")
        .wrapInner("<span>");
    $("h2")
        .wrapInner("<span>");
});

ocpu.seturl("../R");

$(document).ready(function() {
    var pattern = new RegExp("account");
    var features_categories = $('select.select').map(function() {
        return this.value;
    }).get();
    var features_prom_area = $('input:checked.checkbox').map(function() {
        return this.value;
    }).get();
    var features = features_categories.concat(features_prom_area);
    var n = parseInt($('#users_number').val(), 10);
    var speed = parseInt($('#tradeoff').val(), 10);

    $("#submit_button").on("click", function() {
        //disable the button to prevent multiple clicks
        $("#submit_button").attr("disabled", "disabled");


        //Refresh Summary and Results
        $('#scores').empty();
        $('#sum_followers').empty().append($('<th class="desc">').text('Total number of users reached:'));
        $('#mean_followers').empty().append($('<th class="desc">').text('Number of users reached per user targeted:'));
        $('#num_rt').empty().append($('<th class="desc">').text('Expected number of retweet:'));
        $('#lag').empty().append($('<th class="desc">').text('First user will share in:'));
        $('#3rdQlag').empty().append($('<th class="desc">').text('75% of users will share in:'));


        //Display loading animation
        $('<a id="wait" class="wait"> <img src="images/ajax-loader.gif" border="0" alt="Loading bar" /> </a>').appendTo('#results');

        $(document.body).animate({
            'scrollTop': $('#results').offset().top
        }, 500);
        //Perform the request
        var req = ocpu.rpc("getUsers", {
            features_: features,
            n: n,
            speed: speed
        }, function(json) {

            var data = json[0],
                sum_followers = json[1],
                mean_followers = json[2],
                num_rt = json[3],
                min_share_time = json[4],
                thirdQ_share_time = json[5];

            //Display Summary
            $('#sum_followers').append($('<th class="desc">').text(sum_followers));
            $('#mean_followers').append($('<th class="desc">').text(parseInt(mean_followers, 10)));
            $('#num_rt').append($('<th class="desc">').text(parseInt(num_rt, 10)));
            $('#lag').append($('<th class="desc">').text(min_share_time + ' days'));
            $('#3rdQlag').append($('<th class="desc">').text(thirdQ_share_time + ' days'));

            //Remove loading animation
            $('#wait').remove();
            $.each(data, function(i, item) {

                //Append one user to score if is account is not inactive
                if (!pattern.test(item.screen_name)) {
                    var $tr = $('<tr id="user">');

                    $tr.append(
                        $('<td id="pic" class="pic">').html('<a target="_blank" href="https://twitter.com/' + item.screen_name + '"><img src=' + item.pic_urls + '></a>'),
                        $('<td id="screen_name" class="screen_name">').html('<a target="_blank" href="https://twitter.com/' + item.screen_name + '">@' + item.screen_name + '</a>'),
                        $('<td id="score" class="score">').text(item.score.toFixed(1)),
                        $('<td id="klout" class="klout">').text(item.klout.toFixed(1)));

                    $tr.appendTo('#scores');
                }
            });
            $(document.body).animate({
                'scrollTop': $('#results').offset().top
            }, 500);

        });



        //if R returns an error, alert the error message
        req.fail(function() {
            alert("Server error: " + req.responseText);
        });

        //after request complete, re-enable the button 
        req.always(function() {
            $("#submit_button").removeAttr("disabled");
        });
    });
});