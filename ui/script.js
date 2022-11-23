var PlayerJobs = []

$(document).ready(function(){

    $("body").on("click", ".job-card", function(e) {
        e.preventDefault();

        var jobData = $(this).data('jobData');

        if (jobData.active) {
            SetPopUp({
                title: "Go Off Duty",
                description: "Are you sure you want to go off duty?",
                buttons: [
                    {
                        title: "Cancel",
                        color: "red"
                    },
                    {
                        title: "Confirm",
                        cb: () => {
                            $.post('https://fzd_multijob/setActiveJob', JSON.stringify({
                                job: jobData
                            })).done(function(data) {
                                $("#jobs").empty();
                                getPlayerJobs()
                            });
                        }
                    }
                ]
            })
        } else {
            SetPopUp({
                title: "Go On Duty",
                description: `Are you sure you want to go on duty as this ${jobData.label}?`,
                buttons: [
                    {
                        title: "Cancel",
                        color: "red"
                    },
                    {
                        title: "Accept",
                        cb: () => {
                            $.post('https://fzd_multijob/setActiveJob', JSON.stringify({
                                job: jobData
                            })).done(function(data) {
                                $("#jobs").empty();
                                getPlayerJobs()
                            });
                        }
                    }
                ]
            })
        }
    });
});

async function getPlayerJobs() {
    await $.post('https://fzd_multijob/getPlayerJobs', JSON.stringify({}), function(jobs) {
        PlayerJobs = jobs;
    });

    // for (let i = 0; i < PlayerJobs.length; i++) {
    //     const job = PlayerJobs[i];

    //     $("#jobs").append(`
    //         <div class="job-card data-job=${job.name}">
    //             <div class="job-name">${job.label}</div>
    //             <div class="job-grade">${job.gradeLabel}</div>
    //             <div class="job-status">${job.active && 'On Duty' || 'Off Duty'}</div>
    //         </div>
    //     `);
    // }

    if (PlayerJobs.length > 0) {
        $.each(PlayerJobs, function(index, job) {
            var elem = `
                <div class="job-card" id="job-${index}">
                    <div class="job-name">${job.label}</div>
                    <div class="job-grade">${job.gradeLabel}</div>
                    <div class="job-status">${job.active && 'On Duty' || 'Off Duty'}</div>
                </div>
            `
            $("#jobs").append(elem);
            $(`#job-${index}`).data('jobData', job)
        });
    }
}

window.addEventListener("load", () => {
    getPlayerJobs();
});

window.addEventListener('message', function(event) {
    console.log(event.data.type)
    switch (event.data.type) {
        case "refreshJobs":
            $("#jobs").html("");
            console.log('test')
            break;
    };
});